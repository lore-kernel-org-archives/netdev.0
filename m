From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net:dsa: fix dsa_dst_del_ds()
Date: Wed, 4 Jan 2017 03:45:53 +0100
Message-ID: <20170104024553.GC10768@lunn.ch>
References: <1481129585-9084-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, netdev@vger.kernel.org,
        volodymyr.bendiuga@gmail.com
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42588 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758805AbdADCqa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 21:46:30 -0500
Content-Disposition: inline
In-Reply-To: <1481129585-9084-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 05:53:05PM +0100, Volodymyr Bendiuga wrote:
> When dsa_dst_del_ds() is called, do not free the whole list,
> instead, only decrement refcount for the switch tree. The list
> will be deleted in dsa_put_dst() if refcount is 0. Nothing
> really needs to be freed for dsa switch, therefore dsa_free_ds()
> is empty. kref_put() will print warning if dsa_free_ds() is not
> passed as a parameter to it.

This does not look correct. I would expect there to be some symmetry.

The dst gets allocated in _dsa_register_switch(), so it should be
freed somewhere in or under _dsa_unregister_switch(). As you say, it
can be freed from dsa_free_dst(), but that is not called from
_dsa_unregister_switch().

dsa_dst_add_ds() and dsa_dst_del_ds() currently look symmetric.  Add
increments the ref count for the tree, del decrements it. When it
reaches zero, the tree is freed. 

dsa_dst_del_ds() is called from _dsa_unregister_switch(), which gives
us the symmetry with _dsa_register_switch().

What problem are you actually seeing? A double free? A use after free?

Thanks
	Andrew
