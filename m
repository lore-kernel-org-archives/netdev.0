From: Jiri Pirko <jiri@resnulli.us>
Subject: switchdev fib offload issues
Date: Mon, 18 Apr 2016 17:47:57 +0200
Message-ID: <20160418154757.GA2059@nanopsycho.amit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, dsa@cumulusnetworks.com, f.fainelli@gmail.com,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35698 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcDRPsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 11:48:01 -0400
Received: by mail-wm0-f53.google.com with SMTP id a140so126450936wma.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 08:48:00 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

The current situation of fib offloading is not good, I believe we need
to make some changes, therefore I'm writing this email. Please read,
think and comment.

Currently what we have is that for every fib entry inserted into a table,
there is a call to switchdev:
 fib_table_insert->switchdev_fib_ipv4_add
Driver then pushes fib entry down to HW. So far good.

However, if for any reason the switchdev add operation fails, there is an
abort function called (switchdev_fib_ipv4_abort). This function does two
things which are both unfortunate in many usecases:
1) evicts all fib entries from HW leaving all processing done in kernel
    - For Spectrum ASIC this means that all traffic running at 100G between
      all ports is immediately downgraded to ~1-3Gbits
    - Also this happens silently, user knows nothing about anything went wrong,
      only forwarding performance suddenly sucks.

2) sets net->ipv4.fib_offload_disabled = true
    - That results in no other fib entry being offloaded, forever,
      until net is removed and added again, machine reboot is required
      in case if init_ns

These 2 issues makes fib offload completely unusable. So I propose
to start thinking about fixing this.

I believe that although the current behaviour might be good for default,
user should be able to change it by setting a different policy. This
policy will allow to propagate offload error to user.

Note that user already has to handle fib add errors which are independent
on particular fib entry. That is a case of insufficient memory (-ENOBUFS).
In fact, when offload fails, that is most likely also due to insufficient
resources in HW.

Proposed solutions (ideas):
1) per-netns. Add a procfs file:
	/proc/sys/net/ipv4/route/fib_offload_error_policy
	  with values: "evict" - default, current behaviour
                       "fail" - propagate offload error to user
	The policy value would be stored in struct net.

2) per-VRF/table
	When user creates a VRF master, he specifies a table ID
	this VRF is going to use. I propose to extend this so
	he can pass a policy ("evict"/"fail").
	The policy value would be stored in struct fib_table or
	struct fib6_table. The problem is that vfr only saves
	table ID, allocates dst but does not actually create
	table. That might be created later. But I think this
	could be resolved.

3) per-VFR/master_netdev
	In this case, the policy would be also set during
	the creation of VFR master. From user perspective,
	this looks same as 2)
	The policy value would be stored in struct net_vrf (vrf private).

Thoughts?

Thanks!

Jiri
