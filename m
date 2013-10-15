From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Tue, 15 Oct 2013 17:34:57 +0800
Message-ID: <525D0C41.2080407@oracle.com>
References: <52590DFE.6080203@oracle.com>	 <20131014111958.GE11739@zion.uk.xensource.com>	 <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050308030204060306060203"
Cc: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, ANNIE LI <annie.li@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30778 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab3JOJfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 05:35:11 -0400
In-Reply-To: <1381826609.24708.135.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050308030204060306060203
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit


On 2013-10-15 16:43, Ian Campbell wrote:
> On Tue, 2013-10-15 at 10:44 +0800, jianhai luan wrote:
>> On 2013-10-14 19:19, Wei Liu wrote:
>>> On Sat, Oct 12, 2013 at 04:53:18PM +0800, jianhai luan wrote:
>>>> Hi Ian,
>>>>     I meet the DomU's network interface hung issue recently, and have
>>>> been working on the issue from that time. I find that DomU's network
>>>> interface, which send lesser package, will hung if Dom0 running
>>>> 32bit and DomU's up-time is very long.  I think that one jiffies
>>>> overflow bug exist in the function tx_credit_exceeded().
>>>>     I know the inline function time_after_eq(a,b) will process jiffies
>>>> overflow, but the function have one limit a should little that (b +
>>>> MAX_SIGNAL_LONG). If a large than the value, time_after_eq will
>>>> return false. The MAX_SINGNAL_LONG should be 0x7fffffff at 32-bit
>>>> machine.
>>>>     If DomU's network interface send lesser package (<0.5k/s if
>>>> jiffies=250 and credit_bytes=ULONG_MAX), jiffies will beyond out
>>>> (credit_timeout.expires + MAX_SIGNAL_LONG) and time_after_eq(now,
>>>> next_credit) will failure (should be true). So one timer which will
>>>> not be trigger in short time, and later process will be aborted when
>>>> timer_pending(&vif->credit_timeout) is true. The result will be
>>>> DomU's network interface will be hung in long time (> 40days).
>>>>     Please think about the below scenario:
>>>>     Condition:
>>>>       Dom0 running 32-bit and HZ = 1000
>>>>       vif->credit_timeout->expire = 0xffffffff, vif->remaining_credit
>>>> = 0xffffffff, vif->credit_usec=0 jiffies=0
>>>>       vif receive lesser package (DomU send lesser package). If the
>>>> value is litter than 2K/s, consume 4G(0xffffffff) will need 582.55
>>>> hours. jiffies will large than 0x7ffffff. we guess jiffies =
>>>> 0x800000ff, time_after_eq(0x800000ff, 0xffffffff) will failure, and
>>>> one time which expire is 0xfffffff will be pended into system. So
>>>> the interface will hung until jiffies recount 0xffffffff (that will
>>>> need very long time).
>>> If I'm not mistaken you meant time_after_eq(now, next_credit) in
>>> netback. How does next_credit become 0xffffffff?
>> I only assume the value is 0xfffffff, and the value of next_credit
>> isn't  point. If the delta between now and next_credit larger than
>> ULONG_MAX, time_after_eq will do wrong judge.
> So it sounds like we need a timer which is independent of the traffic
> being sent to keep credit_timeout.expires rolling over.
>
> Can you propose a patch?

Because credit_timeout.expire always after jiffies, i judge the value 
over the range of time_after_eq() by time_before(now, 
vif->credit_timeout.expires). please check the patch.
>
> Ian.
>
>>> Wei.
>>>
>>>>     If some error exist in above explain, please help me point it out.
>>>>
>>>> Thanks,
>>>> Jason
>


--------------050308030204060306060203
Content-Type: text/plain; charset=gb18030;
 name="0001-Process-the-wrong-judge-of-time_after_eq.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-Process-the-wrong-judge-of-time_after_eq.patch"

RnJvbSBmMDhjNTg0Y2ExZjM5M2Y2NTU5YjU4YjZiNGM5ZTI1OWMzMTMyNTllIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBKYXNvbiBMdWFuIDxqaWFuaGFpLmx1YW5Ab3JhY2xl
LmNvbT4KRGF0ZTogVHVlLCAxNSBPY3QgMjAxMyAxNzowNzo0OSArMDgwMApTdWJqZWN0OiBb
UEFUQ0hdIFByb2Nlc3MgdGhlIHdyb25nIGp1ZGdlIG9mIHRpbWVfYWZ0ZXJfZXEoKS4KCklm
IG5ldGZyb250IHNlbmQgbGVzc2VyIHBhY2thZ2UsIHRoZSBkZWx0YSBiZXR3ZWVuIG5vdyBh
bmQgbmV4dF9jcmVkaXQgd2lsbCBiZSBvdXQgcmFuZ2Ugb2YgdGltZV9hZnRlcl9xZSgpIGFu
ZCB0aGUgZnVuY3Rpb24gd2lsbCBkbyB3cm9uZyBqdWRnZS4gQmVjYXVzZSB0aGUgZXhwaXJl
cyBhbHdheXMgYWZ0ZXIgamlmZmllcywgd2UganVkZ2UgdGhlIGNvbmRpdGlvbiBieSB0aW1l
X2JlZm9yZShub3csIHZpZi0+Y3JlZGl0X3RpbWVvdXQuZXhwaXJlcykuCgpTaWduZWQtb2Zm
LWJ5OiBKYXNvbiBMdWFuIDxqaWFuaGFpLmx1YW5Ab3JhY2xlLmNvbT4KLS0tCiBkcml2ZXJz
L25ldC94ZW4tbmV0YmFjay9uZXRiYWNrLmMgfCAgICAzICsrLQogMSBmaWxlcyBjaGFuZ2Vk
LCAyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVy
cy9uZXQveGVuLW5ldGJhY2svbmV0YmFjay5jIGIvZHJpdmVycy9uZXQveGVuLW5ldGJhY2sv
bmV0YmFjay5jCmluZGV4IGYzZTU5MWMuLjgwMzZjZTYgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMv
bmV0L3hlbi1uZXRiYWNrL25ldGJhY2suYworKysgYi9kcml2ZXJzL25ldC94ZW4tbmV0YmFj
ay9uZXRiYWNrLmMKQEAgLTExOTUsNyArMTE5NSw4IEBAIHN0YXRpYyBib29sIHR4X2NyZWRp
dF9leGNlZWRlZChzdHJ1Y3QgeGVudmlmICp2aWYsIHVuc2lnbmVkIHNpemUpCiAJCXJldHVy
biB0cnVlOwogCiAJLyogUGFzc2VkIHRoZSBwb2ludCB3aGVyZSB3ZSBjYW4gcmVwbGVuaXNo
IGNyZWRpdD8gKi8KLQlpZiAodGltZV9hZnRlcl9lcShub3csIG5leHRfY3JlZGl0KSkgewor
CWlmICh0aW1lX2FmdGVyX2VxKG5vdywgbmV4dF9jcmVkaXQpIHx8CisJCXVubGlrZWx5KHRp
bWVfYmVmb3JlKG5vdywgdmlmLT5jcmVkaXRfdGltZW91dC5leHBpcmVzKSkpIHsKIAkJdmlm
LT5jcmVkaXRfdGltZW91dC5leHBpcmVzID0gbm93OwogCQl0eF9hZGRfY3JlZGl0KHZpZik7
CiAJfQotLSAKMS43LjYuNQoK
--------------050308030204060306060203--
