From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Tue, 19 Jan 2016 09:38:54 -0500
Message-ID: <569E4A7E.4080301@gmail.com>
References: <CACT4Y+YjpSKvD5t8e6wKzE8+j3rFzf_Ep+23WjW1Mg3ws6cOCw@mail.gmail.com>
 <20160115190106.GG6074@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:32893 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755548AbcASOi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 09:38:58 -0500
In-Reply-To: <20160115190106.GG6074@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2016 02:01 PM, Marcelo Ricardo Leitner wrote:
> On Wed, Jan 13, 2016 at 10:52:31AM +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> The following program causes use-after-free in __sctp_connect:
>>
> ...
>> INFO: Freed in sctp_association_put+0x150/0x250 age=0 cpu=3 pid=15267
>> [<      none      >] __slab_free+0x1fc/0x320 mm/slub.c:2678
>> [<     inline     >] slab_free mm/slub.c:2833
>> [<      none      >] kfree+0x2a8/0x2d0 mm/slub.c:3662
>> [<     inline     >] sctp_association_destroy net/sctp/associola.c:424
>> [<      none      >] sctp_association_put+0x150/0x250 net/sctp/associola.c:860
>> [<      none      >] sctp_wait_for_connect+0x37c/0x4f0 net/sctp/socket.c:7067
>                          ^^^^^^^^^^^^^^
>> [<      none      >] __sctp_connect+0x905/0xb90 net/sctp/socket.c:1215
>> [<      none      >] __sctp_setsockopt_connectx+0x198/0x1d0
>> net/sctp/socket.c:1328
>> [<     inline     >] sctp_setsockopt_connectx net/sctp/socket.c:1360
>> [<      none      >] sctp_setsockopt+0x226/0x3630 net/sctp/socket.c:3728
>> [<      none      >] sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2642
>> [<     inline     >] SYSC_setsockopt net/socket.c:1752
>> [<      none      >] SyS_setsockopt+0x158/0x240 net/socket.c:1731
>> [<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
>> arch/x86/entry/entry_64.S:185
> 
> This one may sher some light on that other socket leak one, because the
> association shouldn't have been freed at that point.
> Now, how it managed to unbalance that refcnt, hmm...
> 

The free may be a result of implicit close when the program ends.  If the thread
is still waiting for connect to finish when the program ends, we may end up
in a situation when the association has been freed, but the ref held by wait_for_connect
prevents the destruction.  When wait_for_connect finishes in puts the ref and
causes the destruction.

What I am guessing is happing is the wait_for_connect doesn't catch the error condition
correctly and thus __sctp_connect() doesn't think there was and error and references
the assoc which was just destroyed.

-vlad
