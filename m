From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Re: Macvlan WARNiNGS about duplicate sysfs filenames (Was [GIT] Networking)
Date: Wed, 10 Sep 2014 13:32:00 +0400
Message-ID: <CAChDUfQtoi2ZeeqdHE_RghyUxdE4TBBOGcnyRmfFTthUVskWpw@mail.gmail.com>
References: <20140907.164109.1944849896872238507.davem@davemloft.net>
	<20140908212514.GA2348@awork2.anarazel.de>
	<CAHA+R7NCwhMaWX0Mhr7AqHH4x5RZ6TEEiJB7906yVzQouXD3Lg@mail.gmail.com>
	<20140909234806.GG24649@awork2.anarazel.de>
	<20140909235534.GH24649@awork2.anarazel.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bacbb70562c680502b2b9a1
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140909235534.GH24649@awork2.anarazel.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--047d7bacbb70562c680502b2b9a1
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Sep 10, 2014 at 3:55 AM, Andres Freund <andres@anarazel.de> wrote:
> On 2014-09-10 01:48:06 +0200, Andres Freund wrote:
>> On 2014-09-09 15:43:55 -0700, Cong Wang wrote:
>> > On Mon, Sep 8, 2014 at 2:25 PM, Andres Freund <andres@anarazel.de> wrote:
>> > > Hi,
>> > >
>> > > (don't have netdev archived, thus answering here, sorry)
>> > >
>> > > On 2014-09-07 16:41:09 -0700, David Miller wrote:
>> > >> Alexander Y. Fomichev (1):
>> > >>       net: prevent of emerging cross-namespace symlinks
>> > >
>> >
>> > Since you are quoting this change, are you saying it causes
>> > the following kernel warning?
>>
>> I thought it might be a likely candidate; but I'm not sure at all. I'll
>> verify it as soon as I can reboot the machine a couple of times (end of
>> week-ish).
>>
>> > > I'm seeing WARNINGs like:
>> > > [ 1005.269134] ------------[ cut here ]------------
>> > > [ 1005.269148] WARNING: CPU: 6 PID: 4213 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x80()
>> > > [ 1005.269150] sysfs: cannot create duplicate filename '/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0/upper_mv-eth0'
>> >
>> >
>> > Is there a network device named upper_mv-eth0 existed in your system
>> > before you created macvlan?
>>
>> No, there wasn't any. Afaics, the sequence is:
>> 1) macvlan mv-eth0 is created in global namespace
>> 2) mv-eth0 is moved (by systemd-nsspawn) into a new network
>>    namespace. Leaving a dangling symlink in the host namespace
>> /devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0/upper_mv-eth0 pointing toward
>> ../mv-eth0
>> which doesn't exist in the external namespace. The new namespace seems
>> to have broken 'lower_bond0' symlink as well
>>
>> This seems to be the case (and probably the actual root cause) in
>> slightly earlier kernels as well.
>> What changed seems to be that:
>> 3) macvlan mv-eth0 is destroyed in the namespace (potentially while
>>    tearing it down)
>> 4) Now there's a broken symlink that doesn't make sense in any namespace
>> 5) mv-eth0 can't be created anew
>>
>> It seems that 3-5 didn't happen that way on older kernels. The most
>> recent where it's not persistently broken is 3.16.0-rc7-00007 -
>> 31dab719f. The oldest where I know it's reproducible is
>> 3.17.0-rc4-andres-00135-g35af256.
>
> I've reproduced the problem on another machine where it's perfectly
> reproducible (except being about mv-bond0).

did you mean this is a macvlan which has bond as a real device?
hmm... current implementation of bonding unconditionally
refuses to switch ns due to NETIF_F_NETNS_LOCAL flag afaik,
macvlan steals flags from lowerdev so it should behave the same.
just to clarify: custom patches?

btw, could i ask you to try attached patch?
in short, my initial assumption we don't need check ns
in __netdev_adjacent_dev_insert was incorrect, I do really forgot (at
least) this :(

/* When creating macvlans or macvtaps on top of other macvlans - use
* the real device as the lowerdev.

so we can create broken links playing with macvlan in container.

diff --git a/net/core/dev.c b/net/core/dev.c
index ab9a165..12f496f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4841,7 +4841,9 @@ static int __netdev_adjacent_dev_insert(struct
net_device *dev,
        pr_debug("dev_hold for %s, because of link added from %s to %s\n",
                 adj_dev->name, dev->name, adj_dev->name);

-       if (netdev_adjacent_is_neigh_list(dev, dev_list)) {
+       if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+           net_eq(dev_net(dev),dev_net(adj_dev))) {
+
                ret = netdev_adjacent_sysfs_add(dev, adj_dev, dev_list);
                if (ret)
                        goto free_adj;
@@ -4862,7 +4864,8 @@ static int __netdev_adjacent_dev_insert(struct
net_device *dev,
        return 0;

 remove_symlinks:
-       if (netdev_adjacent_is_neigh_list(dev, dev_list))
+       if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
+           net_eq(dev_net(dev),dev_net(adj_dev)))
                netdev_adjacent_sysfs_del(dev, adj_dev->name, dev_list);
 free_adj:
        kfree(adj);

> After reverting only the
> aforementioned 4c75431ac352063 it works again.
> As I said above, I'm not sure whether 4c75431ac352063 is the actual
> culprit, but it certainly made the problem visible. How are these
> upper_$if/lower_$if supposed to behave when the macvlan and the
> underlying device are in differing namespaces?
>
> Greetings,
>
> Andres Freund



-- 
Best regards.
       Alexander Y. Fomichev <git.user@gmail.com>

--047d7bacbb70562c680502b2b9a1
Content-Type: application/x-download;
	name="netdev_adjacent_dev_insert.patch"
Content-Disposition: attachment; filename="netdev_adjacent_dev_insert.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hzwe7jl20

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMKaW5kZXggYWI5YTE2
NS4uMTJmNDk2ZiAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZGV2LmMKKysrIGIvbmV0L2NvcmUvZGV2
LmMKQEAgLTQ4NDEsNyArNDg0MSw5IEBAIHN0YXRpYyBpbnQgX19uZXRkZXZfYWRqYWNlbnRfZGV2
X2luc2VydChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LAogCXByX2RlYnVnKCJkZXZfaG9sZCBmb3Ig
JXMsIGJlY2F1c2Ugb2YgbGluayBhZGRlZCBmcm9tICVzIHRvICVzXG4iLAogCQkgYWRqX2Rldi0+
bmFtZSwgZGV2LT5uYW1lLCBhZGpfZGV2LT5uYW1lKTsKIAotCWlmIChuZXRkZXZfYWRqYWNlbnRf
aXNfbmVpZ2hfbGlzdChkZXYsIGRldl9saXN0KSkgeworCWlmIChuZXRkZXZfYWRqYWNlbnRfaXNf
bmVpZ2hfbGlzdChkZXYsIGRldl9saXN0KSAmJgorCSAgICBuZXRfZXEoZGV2X25ldChkZXYpLGRl
dl9uZXQoYWRqX2RldikpKSB7CisJCQogCQlyZXQgPSBuZXRkZXZfYWRqYWNlbnRfc3lzZnNfYWRk
KGRldiwgYWRqX2RldiwgZGV2X2xpc3QpOwogCQlpZiAocmV0KQogCQkJZ290byBmcmVlX2FkajsK
QEAgLTQ4NjIsNyArNDg2NCw4IEBAIHN0YXRpYyBpbnQgX19uZXRkZXZfYWRqYWNlbnRfZGV2X2lu
c2VydChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LAogCXJldHVybiAwOwogCiByZW1vdmVfc3ltbGlu
a3M6Ci0JaWYgKG5ldGRldl9hZGphY2VudF9pc19uZWlnaF9saXN0KGRldiwgZGV2X2xpc3QpKQor
CWlmIChuZXRkZXZfYWRqYWNlbnRfaXNfbmVpZ2hfbGlzdChkZXYsIGRldl9saXN0KSAmJgorCSAg
ICBuZXRfZXEoZGV2X25ldChkZXYpLGRldl9uZXQoYWRqX2RldikpKQogCQluZXRkZXZfYWRqYWNl
bnRfc3lzZnNfZGVsKGRldiwgYWRqX2Rldi0+bmFtZSwgZGV2X2xpc3QpOwogZnJlZV9hZGo6CiAJ
a2ZyZWUoYWRqKTsK
--047d7bacbb70562c680502b2b9a1--
