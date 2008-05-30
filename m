From: Ray Lee <ray-lk@madrabbit.org>
Subject: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Fri, 30 May 2008 09:31:19 -0700
Message-ID: <48402BD7.2080705@madrabbit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tapsys.com ([72.36.178.242]:54203 "EHLO tapsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbYE3RF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 13:05:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Oy, resending. Freakin' gmail; sorry for the base64 encoded noise.)

On Mon, May 26, 2008 at 6:28 AM, Ilpo <ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 26 May 2008, Ingo Molnar wrote:
>
>> in an overnight -tip testruns that is based on recent -git i got two
>> stuck TCP connections:
>>
>> Active Internet connections (w/o servers)
>> Proto Recv-Q Send-Q Local Address               Foreign Address             State
>> tcp        0 174592 10.0.1.14:58015             10.0.1.14:3632              ESTABLISHED
>> tcp    72134      0 10.0.1.14:3632              10.0.1.14:58015             ESTABLISHED
>>
>> on a previously reliable machine. That connection has been stuck for 9
>> hours so it does not time out, etc. - and the distcc run that goes over
>> that connection is stuck as well.
>>
>> kernel config is attached.
>>
>> in terms of debugging there's not much i can do i'm afraid. It's not
>> possible to get a tcpdump of this incident, given the extreme amount of
>> load these testboxes handle.
>
> ...but you can still tcpdump that particular flow once the situation is
> discovered to see if TCP still tries to do something, no? One needs to
> tcpdump couple of minutes at minimum. Also please get /proc/net/tcp for
> that flow around the same time.
>
>> This problem started sometime around rc3
>> and it occured on two boxes (on a laptop and on a desktop), both are SMP
>> Core2Duo based systems. I never saw this problem before on thousands of
>> similar bootups, so i'm 99.9% sure the bug is either new or became
>> easier to trigger.
>>
>> It's not possible to bisect it as it needs up to 12 hours of heavy
>> workload to trigger. The incident happened about 5 times since the first
>> incident a couple of days ago - 4 times on one box and once on another
>> box. The first failing head i became aware of was 78b58e549a3098. (-tip
>> has other changes beyond -git but changes nothing in networking.)

Okay, but in some sense you've already bisected this somewhat. I'm
assuming that your testing uses the latest tip and is refreshed daily.

If that's the case, then I would (possibly naively) expect the culprit
to show up in a:
  git log -p v2.6.26-rc1..78b58e549a3098 net/{compat.c,core,ipv4,netfilter,packet,sched,socket.c}

There are only a few commits in there that appear to touch network behavior:

  79d44516b4b178ffb6e2159c75584cfcfc097914
  a1c1f281b84a751fdb5ff919da3b09df7297619f
  62ab22278308a40bcb7f4079e9719ab8b7fe11b5

Reverting just those three and running overnight might provide a clue.
OTOH, I'm in no way a net/ expert, so if you are already working a
debugging strategy then feel free to ignore this. I'm only piping up
as it appears that the troubleshooting has stalled.

> (but there were
> some recent fixes to FRTO and retrans_stamp change could have some
> significance here)?
>
> Other than that, nothing since -rc1 seems suspicious to me (though
> I hardly understand every part of networking).
