From: Thomas Graf <tgraf@infradead.org>
Subject: Re: ipctl - new tool for efficient read/write of net related sysctl
Date: Mon, 7 May 2012 02:14:22 -0400
Message-ID: <20120507061422.GA21089@canuck.infradead.org>
References: <CAHOuc7MQiquWxMZ4YApXXKdsRY_StrTfAK9r_DdkstyYe+kCPQ@mail.gmail.com>
 <9241f146-d0f7-415b-a652-acd1bf34e95a@tahiti.vyatta.com>
 <CAHOuc7PjmcF=EhEUDEqfF_RShezxDqzc+53frNwWqhww8YQ+mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Oskar Berggren <oskar.berggren@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:41005 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab2EGGOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 02:14:25 -0400
Content-Disposition: inline
In-Reply-To: <CAHOuc7PjmcF=EhEUDEqfF_RShezxDqzc+53frNwWqhww8YQ+mA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 06, 2012 at 02:46:01PM +0200, Oskar Berggren wrote:
> 2012/5/6 Stephen Hemminger <stephen.hemminger@vyatta.com>:
> >
> >>
> >> In a project of mine I need to read (and possibly set) many of the
> >> properties
> >> found under /proc/sys/net/ipv4/conf/. This is simple enough, except
> >> that
> >> when you have hundreds of interfaces, it is really slow. In my tests
> >> it takes
> >> about 4 seconds to read a single variable for 700 interfaces. For a
> >> while I
> >> worked around this using the binary sysctl() interface, but this is
> >> deprecated.
> >>
> >
> > What about exposing these as NETLINK attributes? That would be faster
> > and you could do bulk updates.
> 
> 
> This is my first attempt at using NETLINK, so could you please elaborate?
> Below is the generic netlink interface I implemented so far. Any pointers
> on how I should do this differently?

What Stephen means is to use the existing message types RTM_SETLINK
and RTM_GETLINK in the NETLINK_ROUTE family.

This is already partially implemented. See the IFLA_AF_SPEC attribute
carrying IPV4_DEVCONF_ and DEVCONF_ (IPv6). Grep for rtnl_af_register()
and you will find the corresponding implementations.

Feel free to complete these existing interfaces, such as adding write
support to IPv6 or adding support to iproute2 which is currently
lacking.

src/nl-link-list.c in the libnl sources allows you to display the
configurations:

$ src/nl-link-list --details --name virbr0-nic
virbr0-nic ether 52:54:00:cb:da:db master virbr0 <broadcast,multicast> 
    mtu 1500 txqlen 500 weight 0 qdisc noop index 7 
    brd ff:ff:ff:ff:ff:ff state down mode default
    ipv4 devconf:
      forwarding            1  mc_forwarding         0  proxy_arp             0
      accept_redirects      1  secure_redirects      1  send_redirects        1
      shared_media          1  rp_filter             1  accept_source_route   0
      bootp_relay           0  log_martians          0  tag                   0
      arpfilter             0  medium_id             0  noxfrm                0
      nopolicy              0  force_igmp_version    0  arp_announce          0
      arp_ignore            0  promote_secondaries   0  arp_accept            0
      arp_notify            0  accept_local          0  src_vmark             0
      proxy_arp_pvlan       0  
    ipv6 max-reasm-len 64KiB <>
      create-stamp 13.35s reachable-time 40s 898msec retrans-time 1s
      devconf:
      forwarding            1  hoplimit             64  mtu6               1500
      accept_ra             1  accept_redirects      1  autoconf              1
      dad_transmits         1  rtr_solicits          3  rtr_solicit_interval 4s
      rtr_solicit_delay    1s  use_tempaddr          0  temp_valid_lft       7d
      temp_prefered_lft    1d  regen_max_retry       3  max_desync_factor   600
      max_addresses        16  force_mld_version     0  accept_ra_defrtr      1
      accept_ra_pinfo       1  accept_ra_rtr_pref    1  rtr_probe_interval   1m
      accept_ra_rt_info     0  proxy_ndp             0  optimistic_dad        0
      accept_source_route   0  mc_forwarding         0  disable_ipv6          0
      accept_dad            1  force_tllao           0  
