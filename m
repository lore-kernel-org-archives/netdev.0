From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3 net] flow_dissector: fix vlan tag handling
Date: Tue, 25 Oct 2016 10:11:12 +0200
Message-ID: <20161025081112.GB1672@nanopsycho.orion>
References: <20161024214058.1896091-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Eric Garver <e@erig.me>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161024214058.1896091-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Oct 24, 2016 at 11:40:30PM CEST, arnd@arndb.de wrote:
>gcc warns about an uninitialized pointer dereference in the vlan
>priority handling:
>
>net/core/flow_dissector.c: In function '__skb_flow_dissect':
>net/core/flow_dissector.c:281:61: error: 'vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
>As pointed out by Jiri Pirko, the variable is never actually used
>without being initialized first as the only way it end up uninitialized
>is with skb_vlan_tag_present(skb)==true, and that means it does not
>get accessed.
>
>However, the warning hints at some related issues that I'm addressing
>here:
>
>- the second check for the vlan tag is different from the first one
>  that tests the skb for being NULL first, causing both the warning
>  and a possible NULL pointer dereference that was not entirely fixed.
>- The same patch that introduced the NULL pointer check dropped an
>  earlier optimization that skipped the repeated check of the
>  protocol type
>- The local '_vlan' variable is referenced through the 'vlan' pointer
>  but the variable has gone out of scope by the time that it is
>  accessed, causing undefined behavior
>
>Caching the result of the 'skb && skb_vlan_tag_present(skb)' check
>in a local variable allows the compiler to further optimize the
>later check. With those changes, the warning also disappears.
>
>Fixes: 3805a938a6c2 ("flow_dissector: Check skb for VLAN only if skb specified.")
>Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Jiri Pirko <jiri@mellanox.com>
