From: "George Spelvin" <linux@horizon.com>
Subject: Re: get_random_int() should use hash[1]
Date: 16 Aug 2011 06:30:28 -0400
Message-ID: <20110816103028.1360.qmail@science.horizon.com>
References: <20110816.021031.1778295949152117484.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, linux@horizon.com, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:38267 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751581Ab1HPKaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 06:30:30 -0400
In-Reply-To: <20110816.021031.1778295949152117484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From davem@davemloft.net Tue Aug 16 09:10:35 2011
Date: Tue, 16 Aug 2011 02:10:31 -0700 (PDT)
To: linux@horizon.com
Cc: netdev@vger.kernel.org
Subject: Re: get_random_int() should use hash[1]
From: David Miller <davem@davemloft.net>
In-Reply-To: <20110816.020935.717525957035990843.davem@davemloft.net>
References: <20110816090723.18492.qmail@science.horizon.com>
	<20110816.020935.717525957035990843.davem@davemloft.net>
X-Mailer: Mew version 6.3 on Emacs 23.2 / Mule 6.0 (HANACHIRUSATO)
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.2.6 (shards.monkeyblade.net [198.137.202.13]); Tue, 16 Aug 2011 02:10:33 -0700 (PDT)

From: David Miller <davem@davemloft.net>
Date: Tue, 16 Aug 2011 02:09:35 -0700 (PDT)

> From: "George Spelvin" <linux@horizon.com>
> Date: 16 Aug 2011 05:07:23 -0400
> 
>> Re: commit e997d47bff5a467262ef224b4cf8cbba2d3eceea
>> 
>> As long as you're using MD5, you should know that each round only
>> modifies one word of the state.  The order is [0], [3], [2], [1],
>> repeating 64 times.  Thus, on output, word [1] is the "most hashed"
>> word.  If you really wanted word [0], you could just skip the last
>> 3 rounds.
>> 
>> It's not really critical, but as long as you're performing the
>> rounds, you might as well use them...
> 
> Please provide a proper signoff with your change and properly
> "-p1" base your patch.

Not a problem.  This came up in the middle of a rebase operation so I
didn't have a tree immediately at hand to work with.

I'll also get the various uses in net/core/secure_seq.c.

One thing about that commit I'm becoming more concerneed by: I notice that
it eliminates the periodic reseeding of the secret.

While the reduction in the number of random bits was a tradeoff (and it
can be increased to 28 or so), it had two great advantages:
- The usefulness of an attack drops off sharply after 5 minutes (you
  can still attack connections established during the attack window,
  but then you have to guess how much data has been sent across them).
- An initial shortage of seed entropy does not become a persistent
  problem.  Note that late_initcall() is still before any device
  activity, much less entropy pool re-seeding from init scripts.

Put together, an attacker has the system uptime to try to guess
the low-entropy boot seed.  That's not clearly a security improvement.

What I *really* wonder is whether such a change is really -stable
material.  Cc: to Matt Mackall for comment.

It seems at least worth figuring out a way to defer seeding until
after /dev/random reseeding.  (E.g. until first non-loopback
connection is made.)

(There are also both better and faster algorithms than MD5 for
the job, but that's a separate issue.)


Just for example, as long as you're actually willing to spend more CPU
time, you could do *both*.  Compute both a fixed-secret 32-bit value and a
changing-secret 24-bit value and add them together.  Best of both worlds.
