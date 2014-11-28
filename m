From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: tun issue after e0b46d0ee9c: tun: Use iovec iterators
Date: Fri, 28 Nov 2014 20:10:03 -0200
Message-ID: <5478F2BB.9050409@redhat.com>
References: <5478CC27.9040705@redhat.com> <20141128203733.GD29748@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbaK1WKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 17:10:10 -0500
In-Reply-To: <20141128203733.GD29748@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28-11-2014 18:37, Al Viro wrote:
> On Fri, Nov 28, 2014 at 05:25:27PM -0200, Marcelo Ricardo Leitner wrote:
>> Hi,
>>
>> I saw there are tun updates on Dave's queue but none seemed to handle this.
>>
>> I can't use current net-next
>> (799d2fff1858004526ad75d66a5dd8a5cce6ad40) on a kvm hypervisor
>> because tun got clogged somehow. Bisected down to:
>
> Umm...  In host, presumably?
>

Exactly

>> And net/core/datagram.c, skb_copy_datagram_from_iter():
>>          if (copy > 0) {
>>                  int ret;
>>                  if (copy > len)
>>                          copy = len;
>>                  ret = copy_from_iter(skb->data + offset, copy, from);
>>                  if (ret != copy) {
>>                          pr_err("%d ret=%d copy=%d offset=%d
>> len=%d\n", __LINE__, ret, copy, offset, len);
>>                          goto fault;
>>                  }
>>
>>
>> I get, for tun interfaces:
>> [   75.435552] 506 ret=80 copy=90 offset=0 len=90
>> [   75.435563] tun: 1124 0 -14           (null)
>> [   75.499528] 506 ret=80 copy=90 offset=0 len=90
>> [   75.499540] tun: 1124 0 -14           (null)
>>
>> These were 1 drop on 1 interface each
>>
>> And for tap interfaces:
>> [  301.982639] 506 ret=80 copy=90 offset=0 len=90
>> [  301.982649] tun: 1124 0 -14           (null)
>> [  301.988625] 506 ret=80 copy=90 offset=0 len=90
>> [  301.988635] tun: 1124 0 -14           (null)
>> [  301.994762] 506 ret=80 copy=90 offset=0 len=90
>> [  301.994773] tun: 1124 0 -14           (null)
>> [  302.229962] 506 ret=332 copy=342 offset=0 len=342
>> [  302.229972] tun: 1124 0 -14           (null)
>> [  302.230621] 506 ret=332 copy=342 offset=0 len=342
>> [  302.230627] tun: 1124 0 -14           (null)
>> [  302.239065] 506 ret=332 copy=342 offset=0 len=342
>> [  302.239071] tun: 1124 0 -14           (null)
>>
>> It's returning 10 bytes less than the expected... ideas?
>
> Could you print vnet_hdr_sz and sizeof(gso) right after that
> copy_from_iter(&gso, ...)?

Did a:
         else {
                 err = skb_copy_datagram_from_iter(skb, 0, from, len);
+               pr_err("vnet_hdr_sz=%d sizeof(gso)=%lu\n", tun->vnet_hdr_sz, 
sizeof(gso));
                 if (!err && msg_control) {

Got, for tun:
[   50.514165] tun: vnet_hdr_sz=12 sizeof(gso)=10

for tap:
[   82.911840] tun: vnet_hdr_sz=10 sizeof(gso)=10

other values were just as before.

Marcelo
