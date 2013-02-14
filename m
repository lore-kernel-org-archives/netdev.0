From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Thu, 14 Feb 2013 10:28:20 +0100
Message-ID: <511CAE34.3050800@redhat.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<5118FEA9.2080201@redhat.com>
	<1675407061.963254.1360682467627.JavaMail.root@vmware.com>
	<511B739C.8000204@redhat.com>
	<1218897172.1425846.1360812023655.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020502040802090601000703"
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1218897172.1425846.1360812023655.JavaMail.root@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020502040802090601000703
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

  Hi,

>> I've seen you have a notify_ops in the vmci bits.  Do you have different
>> notify ops depending on socket type or something?  Does it make sense to
>> move the notify ops ptr into "struct vsock_sock" maybe?
> 
> The notify stuff only applies to STREAMs.  However, we have two different
> notify impls, one for legacy ESX and one for newer, and we figure out at
> runtime which protocol we're using with the hypervisor and set the
> callbacks appropriately.

Ok.

> The difference between the two is that the
> newer one is much smarter and knows not to signal (the peer) quite so much,
> i.e., it has some basic but sensible flow-control, which improves
> performance quite a bit.

Yea, with that background it makes more sense.  I think we can reduce
number of hooks though.

Looking at vsock_stream_sendmsg:
  * notify_send_init -- needed I guess.
  * notify_send_pre_block -- needed too, I guess you'll force signaling
    the peer here (buffers full and there is more data).
  * notify_send_pre_enqueue + notify_send_post_enqueue look like they
    could easily be folded into stream_enqueue.

> Again, that might not make any sense at all
> for virtio.  Do you need to signal when you enqueue to a ring?  And is
> there coalescing?

Sure virtio signals, we have to if we don't want poll ;)

Usually virtio only signals in case it finds the ring empty, if there
are requests not yet processed by the peer there is no need to signal.
The ring lives in guest memory and to figure whenever the peer has seen
the requests in there we only need a memory barrier, not a vmexit.

In the end it is up to the driver when he signals the peer.  The virtio
net driver goes beyond the simple "signal-when-the-ring-is-empty" and
has some logic for coalescing things when there is a high network load,
while trying to not trade that for high latencies when the virtual nic
is almost idle.

I guess you try archiving something simliar with vsock/vmci using the
notifications, and yes, we might want use them with virtio too some day.
 Most likely not for the first revision though, there are more important
issues to tackle first.

>> And can we make it optional please (i.e. allow the function pointers to
>> be NULL)?
> 
> They were originally allowed to be NULL, but I changed it in the last
> round of patches while moving them into the transport, since I disliked
> the NULL checks so much.  I can put them back, but that's a bigger
> change, and I'm not sure we want to push large patches to Dave right
> now :)

Yea, it's probably better to discuss+collect the refinements and send
them batched.

>> Which problem you are trying to tackle with the notifications?
> 
> It's to do with signaling the peer, or more appropriately, trying to
> avoid signaling the peer when possible.  The naive impl. is to signal
> every time we enqueue or dequeue data (into our VMCI queuepairs).
> But signaling is slow, since it involves a world exit, so we prefer
> not to.  Which means we need to keep track of rate of flow and figure
> out when we should and should not, and that's what all the notification
> stuff does.  It's...ugly...

But makes sense even if it isn't that pretty.

But /me wonders why you maintain the notify state per-call and not
per-socket/queuepair.  For the data flow it shouldn't make a difference
whenever the application does a few send(big-buffer) or many
send(small-buffer) calls.

>>> For the VMCI transport, it indicates if the underlying queuepair is
>>> still around (i.e., make sure we haven't torn it down while sleeping
>>> in a blocking send or receive).  Perhaps it's not the best name?
>>
>> How you'd hit that?  Peer closing the socket while sleeping?  Other
>> thread closing the socket wile sleeping?  Both?
>>
>> I think a state field in struct vsock_sock would be a better solution here.
> 
> Hrm, lemme think about this one.

There is already vsock->sk.sk_state ...

cheers,
  Gerd

--------------020502040802090601000703
Content-Type: text/plain;
 name="0002-af_vsock-don-t-overwrite-sock-state.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0002-af_vsock-don-t-overwrite-sock-state.patch"

RnJvbSBlMDg1YzgxZDNmYzk1YTdlMmU5MzhkZWVjNjU4NDNiYTdjMDBhZmUzIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBHZXJkIEhvZmZtYW5uIDxrcmF4ZWxAcmVkaGF0LmNv
bT4KRGF0ZTogV2VkLCAxMyBGZWIgMjAxMyAxODowMDoxOSArMDEwMApTdWJqZWN0OiBbUEFU
Q0ggMi80XSBhZl92c29jazogZG9uJ3Qgb3ZlcndyaXRlIHNvY2stPnN0YXRlCgpXZSBzZXQg
c29jay0+c3RhdGUgdG8gU1NfQ09OTkVDVElORyBiZWZvcmUgY2FsbGluZyB0aGUgdHJhbnNw
b3J0LApubyBuZWVkIHRvIGRvIHRoYXQgYWdhaW4gYWZ0ZXJ3YXJkcywgdGhlcmVieSBvdmVy
d3JpdGluZyBhbnkKdXBkYXRlcyB0aGUgdHJhbnNwb3J0J3MgY29ubmVjdCBmdW5jdGlvbiBt
aWdodCBoYXZlIGRvbmUuCgpTaWduZWQtb2ZmLWJ5OiBHZXJkIEhvZmZtYW5uIDxrcmF4ZWxA
cmVkaGF0LmNvbT4KLS0tCiBuZXQvdm13X3Zzb2NrL2FmX3Zzb2NrLmMgfCAgICA2ICsrKy0t
LQogMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkKCmRp
ZmYgLS1naXQgYS9uZXQvdm13X3Zzb2NrL2FmX3Zzb2NrLmMgYi9uZXQvdm13X3Zzb2NrL2Fm
X3Zzb2NrLmMKaW5kZXggNTRiYjdiZC4uZTVkMTQ2NyAxMDA2NDQKLS0tIGEvbmV0L3Ztd192
c29jay9hZl92c29jay5jCisrKyBiL25ldC92bXdfdnNvY2svYWZfdnNvY2suYwpAQCAtMTE4
NCwxMSArMTE4NCwxMSBAQCBzdGF0aWMgaW50IHZzb2NrX3N0cmVhbV9jb25uZWN0KHN0cnVj
dCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBzb2NrYWRkciAqYWRkciwKIAkJaWYgKGVyciA8IDAp
CiAJCQlnb3RvIG91dDsKIAotCQkvKiBNYXJrIHNvY2sgYXMgY29ubmVjdGluZyBhbmQgc2V0
IHRoZSBlcnJvciBjb2RlIHRvIGluCisJCS8qIFdoZW4gc3RpbGwgY29ubmVjdGluZyBzZXQg
dGhlIGVycm9yIGNvZGUgdG8gaW4KIAkJICogcHJvZ3Jlc3MgaW4gY2FzZSB0aGlzIGlzIGEg
bm9uLWJsb2NraW5nIGNvbm5lY3QuCiAJCSAqLwotCQlzb2NrLT5zdGF0ZSA9IFNTX0NPTk5F
Q1RJTkc7Ci0JCWVyciA9IC1FSU5QUk9HUkVTUzsKKwkJaWYgKHNvY2stPnN0YXRlID09IFNT
X0NPTk5FQ1RJTkcpCisJCQllcnIgPSAtRUlOUFJPR1JFU1M7CiAJfQogCiAJLyogVGhlIHJl
Y2VpdmUgcGF0aCB3aWxsIGhhbmRsZSBhbGwgY29tbXVuaWNhdGlvbiB1bnRpbCB3ZSBhcmUg
YWJsZSB0bwotLSAKMS43LjkuNwoK
--------------020502040802090601000703
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--------------020502040802090601000703--
