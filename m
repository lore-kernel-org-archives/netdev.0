From: "George Spelvin" <linux@horizon.com>
Subject: get_random_int() should use hash[1]
Date: 16 Aug 2011 05:07:23 -0400
Message-ID: <20110816090723.18492.qmail@science.horizon.com>
Cc: linux@horizon.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:60134 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751824Ab1HPJHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 05:07:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re: commit e997d47bff5a467262ef224b4cf8cbba2d3eceea

As long as you're using MD5, you should know that each round only
modifies one word of the state.  The order is [0], [3], [2], [1],
repeating 64 times.  Thus, on output, word [1] is the "most hashed"
word.  If you really wanted word [0], you could just skip the last
3 rounds.

It's not really critical, but as long as you're performing the
rounds, you might as well use them...

--- drivers/char/random.c.1	2011-08-16 05:02:09.000000000 -0400
+++ drivers/char/random.c.2	2011-08-16 05:02:43.000000000 -0400
@@ -1323,7 +1323,7 @@
 
 	hash[0] += current->pid + jiffies + get_cycles();
 	md5_transform(hash, random_int_secret);
-	ret = hash[0];
+	ret = hash[1];
 	put_cpu_var(get_random_int_hash);
 
 	return ret;

Me, I'd also put jiffies and get_cycles into different words
just on general principles, but that's up to you:

- 	hash[0] += current->pid + jiffies + get_cycles();
+ 	hash[1] += current->pid + jiffies;
+ 	hash[2] += get_cycles();
