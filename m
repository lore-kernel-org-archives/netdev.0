From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Wed, 20 May 2015 17:31:06 -0700
Message-ID: <1432168266.4060.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150514025333.GA3853@gondor.apana.org.au>
	 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514033448.GA5080@gondor.apana.org.au>
	 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514041628.GA5428@gondor.apana.org.au>
	 <20150514042151.GA5482@gondor.apana.org.au>
	 <20150514055824.GB6058@gondor.apana.org.au>
	 <1431614276.27831.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150515000647.GA13821@gondor.apana.org.au>
	 <20150520235346.GA22074@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37500 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbbEUAbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 20:31:08 -0400
Received: by igbsb11 with SMTP id sb11so53198361igb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 17:31:08 -0700 (PDT)
In-Reply-To: <20150520235346.GA22074@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 01:53 +0200, Thomas Graf wrote:
> On 05/15/15 at 08:06am, Herbert Xu wrote:
> > On Thu, May 14, 2015 at 07:37:56AM -0700, Eric Dumazet wrote:
> > >
> > > This solves the corruption thanks Herbert.
> > 
> > Great.
> > 
> > > But wasn't rhashtable meant to be faster ? ;)
> > 
> > Is it, that's news to me :)
> 
> Eric, can you share the scripts you used to test this?

I believe I posted the getaddrinfo C prog already.

Here is the shell script :

# cat getaddrinfo_many.sh 
#!/bin/bash

TRANSACTIONS_PER_JOB=500
JOBS=200

run_netperf() {
  for ((i=0; i<$JOBS; i++)); do
    ./getaddrinfo $TRANSACTIONS_PER_JOB &> $i.out && rm $i.out &
  done
  wait
  return 0
}

run_once() {
  seconds=$(TIMEFORMAT="%R";(time run_netperf) 2>&1)
  total_transactions=$(($TRANSACTIONS_PER_JOB * $JOBS))
  transactions_per_second=$(echo "print $total_transactions / $seconds" | python)
  echo $transactions_per_second
  return 0
}

start_time=$(date +%s)
while true; do
  result=$(run_once)
  current_time=$(date +%s)
  elapsed=$(($current_time - $start_time))
  echo -n "TPS: $result  Seconds Elapsed: $elapsed  Current time: "
  date
done
