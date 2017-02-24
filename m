From: Harald Welte <laforge@gnumonks.org>
Subject: Basic test setup for testing of Kernel GTP-U
Date: Fri, 24 Feb 2017 17:50:59 +0100
Message-ID: <20170224165059.i47wdj6yg3pv6z3p@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schultz <aschultz@tpip.net>, pablo <pablo@netfilter.org>,
        netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        timo lindhorst <timo.lindhorst@travelping.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:35467 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751574AbdBXQvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:51:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

[intentionally breaking the thread here]

On Thu, Feb 23, 2017 at 05:46:57PM +0100, Harald Welte wrote:
> I'll try to cook up some instructions extending
> https://osmocom.org/projects/openggsn/wiki/OpenGGSN to cover also
> sgsnemu for a basic use case of establishing one single tunnel.  That's
> of course like a manual "HOWTO" and not yet anything that can be tested
> automatically.

I've documented the instructions at
https://osmocom.org/projects/linux-kernel-gtp-u/wiki/Basic_Testing

Please let me know any updates/corrections/questions if you try to
reproduce this.  The above instructions were working for me yesterday.

Please find an ASCII export of this below (much less readable than the
wiki).

Regards,
	Harald

h1. Basic Testing

This page documents some basic testing setup for the Kenrel GTP-U code. It follows the below rationale:
* focus on testing the kernel GTP-U module without too much external dependencies
* test GTP-U interoperability of the kernel with at least one other implementation, not just kernel-to-kernel (which currently is not supported in the kernel, as it only implements the GGSN/P-GW role)
* limit testing to SGSN/S-GW and GGSN/P-GW, without a real cellular network (which is possible e.g. using [[OsmoSGSN:]] and [[OsmoPCU:]])

h2. Building / Installing dependencies

In order to follow below test instructions, you will need
* A Linux kernel including the GTP-U driver (@drivers/net/gtp.c@) either compiled-in or as kernel module
* [[libgtpnl]] - the userspace library providing an API around the kernel GTP-U netlink interface
* [[OpenGGSN:]] - a minimal C-language implementation of a 3GPP GGSN, also contains a SGSN-side emulator called [[OpenGGSN:sgsnemu]]
** make sure you use Version 0.93 or later
** make sure you compile it with @--enable-gtp-linux@ enable during the @./configure@ step

You can find some instructions on how to build [[OpenGGSN:]] with support for [[libgtpnl]] and kernel GTP-U at this wiki page: [[OpenGGSN:Kernel_GTP]]

h2. Test setup description

We will run the GGSN natively on the host, and put the emulated SGSN inside a separate network namespace.

The two namespaces are interconnected by a virtual ethernet device using the transfer network 172.31.1.0/24

The GGSN is configured to provide a pool of IP addresses from the 192.168.71.0/24 range.  Each PDP context will be allocated one dynamic address from that pool


h2. Test instructions

h3. create the network namespace for the SGSN

 ip netns add sgsn

h3. add veth to be used between SGSN and GGSN

 ip link add veth0 type veth peer name veth1

h3. remote (SGSN) side of veth device

<pre>
ip link set veth1 netns sgsn
ip netns exec sgsn ip addr add 172.31.1.2/24 dev veth1
ip netns exec sgsn ip link set veth1 up
</pre>

h3. local (GGSN) side of veth device

<pre>
ip addr add  172.31.1.1/24 dev veth0
ip link set veth0 up
</pre>

h3. execute the GGSN on the host

 ggsn -g -c ./ggsn.conf.test

(use the file attached to this wiki page)

The @-g@ option is responsible for activating kernel-GTP support. If you cannot get the example described in this document to work, try the pure GTP-U userspace implementation by removing @-g@ from the above command line.  If it works then, there's something related to Kernel GTP-U that breaks the setup.

h3. execute the emulated SGSN inside the sgsn namespace

 ip netns exec sgsn sgsnemu -d -r 172.31.1.1 -l 172.31.1.2 --defaultroute --createif

h3. verify the existnace of the GTP tunnel

<pre>
ggsn:~# gtp-tunnel list
version 1 tei 1/1 ms_addr 192.168.71.2 sgsn_addr 172.31.1.2
</pre>

h3. further testing

in the @sgsn@ namespace, there's now a default-route that points into the GTP tunnel. You can use this to ping any network address that's reachable to the GGSN host.  If that host is connected to the internet, you can e.g. run a ping command from within the namespace using 

 ip netns exec sgsn ping -c 10 8.8.8.8

which will send some IP packets to 8.8.8.8 via the tun0 device (created by [[OpenGGSN:sgsnemu]]). It will be encapsulated by the userspace GTP-U implementation of sgsnemu, sent via the veth device to the host, where it ends up inthe GTP-U kernel module, decapsulating the package and passing in on to the gtp0 device there.  Anything beyond that point depends on your local routing configuration.

== Building OpenGGSN ==

h1. OpenGGSN and Linux Kernel accelerated GTP-U

OpenGGSN has support to use the Linux kernel GTP-U code to accelerate the data/user plane while still implementing the control plane (GTP-C) in userspace in OpenGGSN.

For more information about the Linux kernel GTP-U code, please see [[linux-kernel-gtp-u:]]

h2. Building OpenGGSN with kernel which has GTP-U support

At the time of writing (2017-01-09) of this wiki, below listed distributions have support of GTP kernels :

* Debian 4.9.1-1~exp1 - Debian's latest experimental build 
* Ubuntu 16.10 kernel 4.8
* OpenSUSE Tumbleweed (stable) 4.8 (.12)
* Fedora 25 kernel 4.8 

Following two Debian kernels do not activate GTP kernel module during build: 4.8.0 and 4.9.0.

*It is expected that complete openbsc project and related dependencies are pre-installed.*

Check if package @libc-ares-dev@ is installed and if not please add it.

Ubuntu 16.10, kernel 4.8.0-30-generic is used. 

* Installing dependencies and build library @libgtpnl@

You can install those packages with:

<pre>
sudo apt install libtalloc-dev libpcsclite libmnl-dev
</pre>

Please follow instructions provided at [[cellular-infrastructure:Build from source]] in order to install following library and projects :

Information about dependencies between Osmocom projects is given at the above link:

* libgtpnl

<pre>
  sudo make install
  sudo ldconfig
</pre>

* libosmocore 
* openggsn

<pre>
./configure --enable-gtp-linux
make 
sudo make install
sudo ldconfig
</pre>

Following message is shown at end of the command: @ ./configure --enable-gtp-linux@ 

<pre>
openggsn Configuration:
  GTP Linux kernel support:			yes
</pre>

This means that appropriate header files are available.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
