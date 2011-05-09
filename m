From: Ben Greear <greearb@candelatech.com>
Subject: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 11:37:37 -0700
Message-ID: <4DC83471.7030701@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000008060108000404070708"
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38342 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab1EIShl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:37:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000008060108000404070708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

These two patches look good to me.  My benchmark has lots of extraneous
overhead (process launch per action, primarily), so the numbers bounce around
quite a bit on different runs, but it seems consistent that removing vlans
is slightly faster, and removing VETH is much faster.

NOTE:  for VETH, it's creating and dealing with pairs..so 500 veth
means 1000 interfaces in the results below.

The script to generate these results is attached.

System is Atom N270, running Fedora 14.  Kernel has HZ 1000,
pre-empt, SMP, compiled for Pentium II.


With patches:

Created 500 veth in 17.874695 seconds (0.03574939 per interface).
Added IP addresses in 23.306214 seconds (0.046612428 per addr).
Deleted 500 veth in 17.023607 seconds. (0.034047214 per interface)

Created 1000 macvlan in 20.005472 seconds (0.020005472 per interface).
Added IP addresses in 24.870693 seconds (0.024870693 per addr).
Deleted 1000 macvlan in 44.899769 seconds. (0.044899769 per interface)

Created 1000 vlan in 21.343862 seconds (0.021343862 per interface).
Added IP addresses in 24.088452 seconds (0.024088452 per addr).
Deleted 1000 vlan in 42.623666 seconds. (0.042623666 per interface)


Without:

Created 500 veth in 22.507598 seconds (0.045015196 per interface).
Added IP addresses in 28.637194 seconds (0.057274388 per addr).
Deleted 500 veth in 34.998733 seconds. (0.069997466 per interface)

Created 1000 macvlan in 27.903848 seconds (0.027903848 per interface).
Added IP addresses in 29.725436 seconds (0.029725436 per addr).
Deleted 1000 macvlan in 58.552433 seconds. (0.058552433 per interface)

Created 1000 vlan in 33.733169 seconds (0.033733169 per interface).
Added IP addresses in 29.755363 seconds (0.029755363 per addr).
Deleted 1000 vlan in 54.858484 seconds. (0.054858484 per interface)

--
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------000008060108000404070708
Content-Type: application/x-perl;
 name="test_macvlans.pl"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="test_macvlans.pl"

#!/usr/bin/perl

use strict;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep clock_gettime clock_getres clock_nanosleep clock stat );

my $i;
my $mx = $ARGV[0];
my $tp = $ARGV[1];
my $dv = "eth0";

if (! defined($tp)) {
  $tp = "macvlan";
}

print "Stopping udev-post, haldaemon, killing udevd.\n";
system("service udev-post stop");
system("service haldaemon stop");
system("killall udevd");

print "Creating $mx $tp.\n";

my $t0 = [gettimeofday];

for ($i = 0; $i<$mx; $i++) {
  my $cmd;
  if ($tp eq "macvlan") {
    my $nm = $dv . "#" . $i;
    $cmd = "./local/sbin/ip link add link $dv up name $nm type macvlan";
  }
  elsif ($tp eq "vlan") {
    my $nm = $dv . "." . $i;
    $cmd = "./local/sbin/ip link add link $dv up name $nm type vlan id $i";
  }
  elsif ($tp eq "veth") {
    my $nm = "veth$i";
    $cmd = "./local/sbin/ip link add link $dv up name $nm type veth peer name ${nm}b";
  }
  system($cmd);
}

my $took = tv_interval($t0);
my $per = $took / $mx;
print "Created $mx $tp in $took seconds ($per per interface).\n";

$t0 = [gettimeofday];
for ($i = 0; $i<$mx; $i++) {
  my $nm;
  if ($tp eq "macvlan") {
    $nm = $dv . "#" . $i;
  }
  elsif ($tp eq "vlan") {
    $nm = $dv . "." . $i;
  }
  elsif ($tp eq "veth") {
    $nm = "veth$i";
  }

  my $ip1 = $i % 250;
  my $ip2 = int($i / 250);
  my $cmd = "./local/sbin/ip addr add 10.1.${ip2}.${ip1} dev $nm";
  system($cmd);
  if ($tp eq "veth") {
    $nm = $nm . "b";
    $cmd = "./local/sbin/ip addr add 10.1.${ip2}.${ip1} dev $nm";
    system($cmd);
  }
}

my $took = tv_interval($t0);
my $per = $took / $mx;
print "Added IP addresses in $took seconds ($per per addr).\n";

$t0 = [gettimeofday];
for ($i = 0; $i<$mx; $i++) {
  my $nm;
  if ($tp eq "macvlan") {
    $nm = $dv . "#" . $i;
  }
  elsif ($tp eq "vlan") {
    $nm = $dv . "." . $i;
  }
  elsif ($tp eq "veth") {
    $nm = "veth$i";
  }
  my $cmd = "./local/sbin/ip link delete $nm";
  system($cmd);
}

my $took = tv_interval($t0);
my $per = $took / $mx;
print "Deleted $mx $tp in $took seconds. ($per per interface)\n";

--------------000008060108000404070708--
