From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: iproute2: Behavioural Bug?
Date: Mon, 24 Aug 2015 14:00:29 +0530
Message-ID: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35737 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbbHXIa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 04:30:29 -0400
Received: by obbwr7 with SMTP id wr7so106999741obb.2
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 01:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I am trying to delete a single tc filter (i.e. specifying its
handle), it is deleting all the
filters with the same priority/preference. i.e. it is ignoring the
handle specified.

But, When I am doing similar activity in hashtable 800: it is deleting only the
specified filter, i.e. it is behaving as expected.

I am unable to comprehend the reason for this difference in behaviour.

Infact, in kernel 2.6.32 all is working as expected. However, in
kernel 3.1 and 4.1 it is having the behaviour as mentioned above.

For example, following set of commands  create a hashtable 15: and add
2 filters to it.

tc filter add dev eth0 parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:2 u32
ht 15:2: match ip src 10.0.0.2 flowid 1:10
tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
ht 15:2: match ip src 10.0.0.3 flowid 1:10

Now following command DELETES ALL THE FILTERS, though it should only
delete FILTER 15:2:3 !
tc filter del dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32

O/p of tc filter show eth0 is this case is blank. As all filters are deleted.


However, similar commands when executed for hashtable 800: is deleting
only the specified filter
tc filter add dev eth0 protocol ip parent 1: prio 5 handle 800:0:2 u32
ht 800:0: match ip src 10.0.0.2 flowid 1:10
tc filter add dev eth0 protocol ip parent 1: prio 5 handle 800:0:3 u32
ht 800:0: match ip src 10.0.0.3 flowid 1:10

tc filter del dev eth0 protocol ip parent 1: prio 5 handle 800:0:2 u32

Above mentioned command only deletes single filter.
O/p of tc filter show eth0 is 2nd case is

filter parent 1: protocol ip pref 5 u32
filter parent 1: protocol ip pref 5 u32 fh 800: ht divisor 1
filter parent 1: protocol ip pref 5 u32 fh 800::3 order 3 key ht 800
bkt 0 flowid 1:10
  match 0a000003/ffffffff at 12
