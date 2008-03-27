From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: O(n^2) or worse ? cat /proc/net/tcp
Date: Thu, 27 Mar 2008 13:49:11 +0200
Message-ID: <20080327114911.GT3700@mea-ext.zmailer.org>
References: <20080323224307.GL3700@mea-ext.zmailer.org> <20080323.162021.184196552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:54734 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021AbYC0LtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 07:49:12 -0400
Received: (mea@mea-ext) by mail.zmailer.org id S3540384AbYC0LtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 13:49:11 +0200
Content-Disposition: inline
In-Reply-To: <20080323.162021.184196552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 23, 2008 at 04:20:21PM -0700, David Miller wrote:
> From: Matti Aarnio <matti.aarnio@zmailer.org>
> Date: Mon, 24 Mar 2008 00:43:07 +0200
> 
> > I have about 750 TCP socket on one multi-threaded server application, and 
> > about 250 on three single-threaded clients.
> > 
> > I did observe odd slowness at first with  "lsof -p .."  program, then at
> > "netstat -na".  Same slowdown happens with:  cat /proc/net/tcp
> > (that 'cat' took 25 seconds...)
> > 
> > Sure this is not earth shatterinly dangerous thing, rather a nuisance
> > when a monitoring application is not as fast as one would expect.
> 
> There have been some improvements in this area over the
> past few releases.
> 
> If you tell us what version you're running we can try to
> dig out the changes that matter.


I cooked up a small perl "client-server application" (at the end) that
opens up several hundred TCP sockets in between its two halfs.
It doesn't do anything else, that is the machine is _IDLE_ after socket
creations:

$ time cat /proc/net/tcp|wc;time cat /proc/net/tcp|wc;time cat /proc/net/tcp|wc
   2215   35650  332250

real    0m35.731s
user    0m0.005s
sys     0m35.721s
   1815   29445  272250

real    0m25.328s
user    0m0.004s
sys     0m25.309s
   1815   30850  272250

real    0m29.521s
user    0m0.004s
sys     0m29.508s


Kernel:
 2.6.25-0.90.rc3.git5.fc9 #1 SMP Tue Mar 4 20:19:33 EST 2008 x86_64 x86_64 x86_64

Machine:

vendor_id       : AuthenticAMD
cpu family      : 15
model           : 35
model name      : AMD Athlon(tm) 64 X2 Dual Core Processor 4400+
stepping        : 2
cpu MHz         : 2211.331

bogomips        : 4425.68



Odd..  Another machine with slightly older kernel is definitely swifter
although it clocks less than half of the bogomips..

$ time cat /proc/net/tcp | wc
   1822   30969  273300

real    0m6.674s
user    0m0.008s
sys     0m6.669s


 2.6.25-0.40.rc1.git2.fc9 #1 SMP Wed Feb 13 17:17:48 EST 2008 x86_64 x86_64 x86_64 GNU/Linux


vendor_id       : AuthenticAMD
cpu family      : 15
model           : 75
model name      : AMD Athlon(tm) 64 X2 Dual Core Processor 4200+
stepping        : 2
cpu MHz         : 1000.000

bogomips        : 2006.08





#!/usr/bin/perl                                                                                                                     
#  Simple test load generator for Linux kernel related                                                                              
#  "cat /proc/net/tcp" performance issue..                                                                                          

use IO::Socket::INET;
my @rd = ();
my @wr = ();

my $rc = fork();
if ($rc == 0) { ## Child                                                                                                            
    $srv = IO::Socket::INET->new( Type => SOCK_STREAM, Listen => 900, LocalPort => 9988,
                                  ReuseAddr => 1, Blocking => 1 );
    while (1) {
        my $s = $srv->accept();
        push @rd, $s;
    }
    exit;
}

sleep 1; # make sure the "server" starts before our client-side does connects..

foreach my $i (1..900) {
    my $s = IO::Socket::INET->new( Proto => TCP, PeerPort => 9988, PeerAddr => 'localhost' );
    push @wr, $s;

};

while (1) {
    sleep 100;
}

exit 0;
