From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/11] net: Fix netdev adjacency tracking
Date: Tue, 18 Oct 2016 11:46:31 -0400 (EDT)
Message-ID: <20161018.114631.1954199143257806104.davem@davemloft.net>
References: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org
To: dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476756953-30923-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Date: Mon, 17 Oct 2016 19:15:42 -0700

> The netdev adjacency tracking is failing to create proper dependencies
> for some topologies. For example this topology
 ...
> hits 1 of 2 problems depending on the order of enslavement. The base set of
> commands for both cases:
 ...
> Case 1 enslave macvlan to the vrf before enslaving the bond to the bridge:
 ...
> Attempts to delete the VRF:
>     ip link delete myvrf
> 
> trigger the BUG in __netdev_adjacent_dev_remove:
 ...
> When the BUG is converted to a WARN_ON it shows 4 missing adjacencies:
>   eth3 - myvrf, mvrf - eth3, bond1 - myvrf and myvrf - bond1
> 
> All of those are because the __netdev_upper_dev_link function does not
> properly link macvlan lower devices to myvrf when it is enslaved.
 ...
> Rather than try to maintain a linked list of all upper and lower devices
> per netdevice, only track the direct neighbors. The remaining stack can
> be determined by recursively walking the neighbors.
> 
> The existing netdev_for_each_all_upper_dev_rcu,
> netdev_for_each_all_lower_dev and netdev_for_each_all_lower_dev_rcu macros
> are replaced with APIs that walk the upper and lower device lists. The
> new APIs take a callback function and a data arg that is passed to the
> callback for each device in the list. Drivers using the old macros are
> converted in separate patches to make it easier on reviewers. It is an
> API conversion only; no functional change is intended.

Series applied, but the recursion is disappointing.

If we run into problems due to kernel stack depth because of this with
some configurations (reasonable or not, if we allow it then it can't
crash the kernel), we will either need to find a way to make this walk
iterative or revert these changes.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
