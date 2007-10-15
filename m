From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/10] [NET]: Avoid unnecessary cloning for ingress
	filtering
Date: Mon, 15 Oct 2007 09:57:45 -0400
Message-ID: <1192456665.4336.57.camel@localhost>
References: <20071014042604.GA11431@gondor.apana.org.au>
	 <E1Igv4p-00030c-00@gondolin.me.apana.org.au>
	 <1192358991.4892.23.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:45983 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759789AbXJON6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 09:58:14 -0400
Received: by an-out-0708.google.com with SMTP id d31so119583and
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 06:58:13 -0700 (PDT)
In-Reply-To: <1192358991.4892.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-14-10 at 06:49 -0400, jamal wrote:
> Once this patchset makes
> it into net-2.6.24 i can do testing on my laptop and provide you any
> further feedback. 

Works on all 4 tests i tried out on net-2.6[1]. GoodStuff Herbert.

Herbert, please look at the comment i sent on the clone vs copy. 

Also, iirc this started as a netfilter optimization thing starting with
tail-calls - can someone (Patrick?) clue me how it helps in that
optimization aspect? 

cheers,
jamal

[1] Didnt try any ipt action, will when i get the chance again. Heres
test 18b):

---
Window1) tc qdisc del dev lo ingress
Window1) tc qdisc add dev lo ingress
Window1) ifconfig dummy0 up
Window1) tcpdump -n -i lo -x -e -t &

Window2) tcpdump -n -i dummy0 -x -e -t &

Window1) tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
match ip dst 127.0.0.1/32 flowid 1:2 \
action pedit munge offset 0 u32 clear pipe \
action mirred egress mirror dev dummy0

Window2) ping -c 1 127.0.0.1

Ping will fail since we are clearing first 4 byte of ip header.

Window1 will show the packet as seen on incoming by lo; the first few
bytes look like:

----
4500 0054 0000 4000 4001 3ca7 7f00 0001
----

Window2 will show the 4 bytes zeroed out as requested of pedit (and as
seen on dummy0)

---
0000 0000 0000 4000 4001 3ca7 7f00 0001
---------



