From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 07:54:36 -0400
Message-ID: <CACP96tRWO+zpQ0OgeOzuA9A==rKSnzS+s7mJBAiCv=vb703LWQ@mail.gmail.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	<1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACP96tRo1OthQqDhPLVgai2vJPkd6macpdkD3MKwePZa8GMUnQ@mail.gmail.com>
	<5385C731.5060709@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:63333 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbaE1Lyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 07:54:38 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so5771222lbi.9
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 04:54:36 -0700 (PDT)
In-Reply-To: <5385C731.5060709@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 7:23 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:


>
> Did you try the scenario where you add many IP addresses to the same
> interface? Try to do a listing of the ip addresses then, should be
> fun.

I did. Here, you try it too :-) attached below is the script I got from Niels.

And yes, while it is "fun" to do "ip addr show dev $IF|grep '\<inet\>'|wc -l",
I think Niels is first trying to scale the address-addition itself first

BTW, I'm not sure it's O(n^2) - we dont have enough data points from
the script below to establish that. Once you optimize fib_sync_up,
I suspect it scales as K * n, where N > 1. FWIW, doing the quick+dirty
thing of just commenting out fib_sync_up as an experiment *halves* the
wallclock time.

$ cat nils.sh
#!/bin/sh
#
# From nisse@southpole.se (Niels Moller)
#  I used the below script. Run, e.g, with arguments
#  eth0 100 add
# to assign 100*255 addresses..
# And to get numbers, I just ran it with time(1).


if [ $# -lt 2 ] ; then
   echo Too few arguments
   exit 1
fi

IF=$1
CNT=$2
if [ $# -gt 2 ] ; then
    CMD=$3
else
    CMD=del
fi

echo "IF $IF CNT $CNT CMD $CMD"

for x in `seq 1 $CNT` ; do
    echo 10.200.$x.x
    for y in `seq 1 255` ; do
        addr="10.200.$x.$y"
        ip address "$CMD" "$addr"/32 dev "$IF"  || echo FAIL: $addr
    done
done
