From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 17:58:53 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0910271744560.31845@localhost.localdomain>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com> <4AE68E23.20205@gmail.com> <4AE69829.9070207@gmail.com> <4AE6A16F.4020002@gmail.com> <20091027100736.5303f1ab@nehalam> <alpine.LFD.2.01.0910271017170.31845@localhost.localdomain>
 <20091027160822.384dc109@nehalam> <alpine.LFD.2.01.0910271636100.31845@localhost.localdomain> <20091027171035.39e18383@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932492AbZJ1A7Z@vger.kernel.org>
In-Reply-To: <20091027171035.39e18383@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 27 Oct 2009, Stephen Hemminger wrote:
> 
> Agreed. Here is the reduced version of the program.
> To run:
>   find /home -printf '%f\n' 2>/dev/null | ./htest -n 100

The timings are very sensitive to random I$ layout at least on Nehalem. 
The reason seems to be that the inner loop is _so_ tight that just 
depending on exactly where the loop ends up, you can get subtle 
interactions with the loop cache.

Look here:

	[torvalds@nehalem ~]$ find /home -printf '%f\n' 2>/dev/null | ./htest -n 100
	Algorithm             Time       Ratio       Max   StdDev
	full_name_hash       1.141899     1.03      4868 263.37
	djb2                 0.980200     1.03      4835 266.05
	string10             0.909175     1.03      4850 262.67
	string10a            0.673915     1.03      4850 262.67
	string10b            0.909374     1.03      4850 262.67
	string_hash17        0.966050     1.03      4805 263.68
	string_hash31        1.008544     1.03      4807 259.37
	fnv32                0.774806     1.03      4817 259.17

what do you think the difference between 'string10', 'string10a' and 
'string10b' are?

None. None what-so-ever. The source code is identical, and gcc generates 
identical assembly language. Yet those timings are extremely stable for 
me, and 'string10b' is 25% faster than the identical string10 and 
string10a functions.

The only difference? 'string10a' starts aligned to just 16 bytes, but that 
in turn happens to mean that the tight inner loop ends up aligned on a 
128-byte boundary. And being cacheline aligned just there seems to matters 
for some subtle micro-architectural reason.

The reason I noticed this is that I wondered what small modifications to 
'string10' would do for performance, and noticed that even _without_ the 
small modifications, performance fluctuated.

Lesson? Microbenchmarks like this can be dangerous and misleading. That's 
_especially_ true if the loop ends up being just tight enough that it can 
fit in some trace cache or similar. In real life, the name hash is 
performance-critical, but at the same time almost certainly won't be run 
in a tight enough loop that you'd ever notice things like that.

		Linus
