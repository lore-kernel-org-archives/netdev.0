From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] net: sctp: fix panic during skb_orphan()
Date: Fri, 09 Aug 2013 20:39:14 -0400
Message-ID: <52058BB2.4010606@gmail.com>
References: <20130809.133720.232424253997869104.davem@davemloft.net>  <1376085487-6466-1-git-send-email-vyasevich@gmail.com> <1376090435.20509.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-sctp@vger.kernel.org, dborkman@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:59375 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968048Ab3HJAjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 20:39:19 -0400
In-Reply-To: <1376090435.20509.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 07:20 PM, Eric Dumazet wrote:
> On Fri, 2013-08-09 at 17:58 -0400, Vlad Yasevich wrote:
>> This patch fixes the following triggered bug ...
>>
>> [  553.109742] kernel BUG at include/linux/skbuff.h:1813!
>> [  553.109766] invalid opcode: 0000 [#1] SMP
>> [  553.109789] Modules linked in: sctp libcrc32c rfcomm [...]
>> [  553.110259]  uinput i915 i2c_algo_bit drm_kms_helper e1000e drm ptp
>> pps_core i2c_core wmi video sunrpc
>> [  553.110320] CPU: 0 PID: 1636 Comm: lt-test_1_to_1_ Not tainted
>> 3.11.0-rc3+ #2
>> [  553.110350] Hardware name: LENOVO 74597D6/74597D6, BIOS 6DET60WW
>> (3.10 ) 09/17/2009
>> [  553.110381] task: ffff88020a01dd40 ti: ffff880204ed0000 task.ti:
>> ffff880204ed0000
>> [  553.110411] RIP: 0010:[<ffffffffa0698017>]  [<ffffffffa0698017>]
>> skb_orphan.part.9+0x4/0x6 [sctp]
>> [  553.110459] RSP: 0018:ffff880204ed1bb8  EFLAGS: 00010286
>> [  553.110483] RAX: ffff8802086f5a40 RBX: ffff880204303300 RCX:
>> 0000000000000000
>> [  553.110487] RDX: ffff880204303c28 RSI: ffff8802086f5a40 RDI:
>> ffff880202158000
>> [  553.110487] RBP: ffff880204ed1bb8 R08: 0000000000000000 R09:
>> 0000000000000000
>> [  553.110487] R10: ffff88022f2d9a04 R11: ffff880233001600 R12:
>> 0000000000000000
>> [  553.110487] R13: ffff880204303c00 R14: ffff8802293d0000 R15:
>> ffff880202158000
>> [  553.110487] FS:  00007f31b31fe740(0000) GS:ffff88023bc00000(0000)
>> knlGS:0000000000000000
>> [  553.110487] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [  553.110487] CR2: 000000379980e3e0 CR3: 000000020d225000 CR4:
>> 00000000000407f0
>> [  553.110487] Stack:
>> [  553.110487]  ffff880204ed1ca8 ffffffffa068d7fc 0000000000000000
>> 0000000000000000
>> [  553.110487]  0000000000000000 ffff8802293d0000 ffff880202158000
>> ffffffff81cb7900
>> [  553.110487]  0000000000000000 0000400000001c68 ffff8802086f5a40
>> 000000000000000f
>> [  553.110487] Call Trace:
>> [  553.110487]  [<ffffffffa068d7fc>] sctp_sendmsg+0x6bc/0xc80 [sctp]
>> [  553.110487]  [<ffffffff8128f185>] ? sock_has_perm+0x75/0x90
>> [  553.110487]  [<ffffffff815a3593>] inet_sendmsg+0x63/0xb0
>> [  553.110487]  [<ffffffff8128f2b3>] ? selinux_socket_sendmsg+0x23/0x30
>> [  553.110487]  [<ffffffff8151c5d6>] sock_sendmsg+0xa6/0xd0
>> [  553.110487]  [<ffffffff81637b05>] ? _raw_spin_unlock_bh+0x15/0x20
>> [  553.110487]  [<ffffffff8151cd38>] SYSC_sendto+0x128/0x180
>> [  553.110487]  [<ffffffff8151ce6b>] ? SYSC_connect+0xdb/0x100
>> [  553.110487]  [<ffffffffa0690031>] ? sctp_inet_listen+0x71/0x1f0
>> [sctp]
>> [  553.110487]  [<ffffffff8151d35e>] SyS_sendto+0xe/0x10
>> [  553.110487]  [<ffffffff81640202>] system_call_fastpath+0x16/0x1b
>> [  553.110487] Code: e0 48 c7 c7 00 22 6a a0 e8 67 a3 f0 e0 48 c7 [...]
>> [  553.110487] RIP  [<ffffffffa0698017>] skb_orphan.part.9+0x4/0x6
>> [sctp]
>> [  553.110487]  RSP <ffff880204ed1bb8>
>> [  553.121578] ---[ end trace 46c20c5903ef5be2 ]---
>>
>> When a SCTP data chunk is created, skb->sk is set by sctp_make_chunk().
>> At a later time, sctp_sendmg() calls sctp_set_owner_w() which will attempt
>> to orphan the skb and correctly set the skb->sk.  The skb_orphan call result
>> in the above crash since skb->sk was set the the destructor was not.
>>
>> The simple solution is to not set skb->sk for DATA chunks (since it
>> will be done later).  Continue to do it for control chunks since
>> sctp needs the sk at a later timer and control chunks are not currently
>> accouted agains socket memory.
>>
>> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
>> ---
>>   net/sctp/sm_make_chunk.c | 8 ++++++--
>>   1 file changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index 780a2d4..4ff7803 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -1385,8 +1385,12 @@ static struct sctp_chunk *sctp_make_chunk(const struct sctp_association *asoc,
>>   	if (sctp_auth_send_cid(type, asoc))
>>   		retval->auth = 1;
>>
>> -	/* Set the skb to the belonging sock for accounting.  */
>> -	skb->sk = sk;
>> +	/* Set the skb to the belonging sock for accounting.  Do not
>> +	 * do this for data chunks as that will be properly set
>> +	 * up later.
>> +	 */
>> +	if (type != SCTP_CID_DATA)
>> +		skb->sk = sk;
>>
>>   	return retval;
>>   nodata:
>
> This is ugly IMHO.

Yes, it is a bit ugly.  The "proper" way is to do accounting for all 
SCTP chunks, but that is a much larger piece of work.

>
> Why not using a dummy destructor ?

It would just be useless once we do proper accounting for all chunks.
But, I'll send a different idea if this is just too ugly.

>
> And I guess this patch is for net-next ?
>

Yes, sorry...

Anyway. I'll send an less ugly alternative...

-vlad

>
>
