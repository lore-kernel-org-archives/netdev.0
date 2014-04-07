From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [RFC] netfilter: ct: flush net_gre->keymap_list only in
 nf_conntrack_proto_gre
Date: Mon, 7 Apr 2014 16:51:58 +0200
Message-ID: <20140407145158.GA25974@localhost>
References: <1396275258-19015-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, vvs@parallels.com,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57686 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760AbaDGOwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 10:52:04 -0400
Content-Disposition: inline
In-Reply-To: <1396275258-19015-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 06:14:18PM +0400, Andrey Vagin wrote:
> nf_ct_gre_keymap_flush() removes a nf_ct_gre_keymap object from
> net_gre->keymap_list and frees the object. But it doesn't clean
> a reference on this object from ct_pptp_info->keymap[dir].
> Then nf_ct_gre_keymap_destroy() may release the same object again.
> 
> So nf_ct_gre_keymap_flush() can be called only when we are sure that
> when nf_ct_gre_keymap_destroy will not be called.
> 
> nf_ct_gre_keymap is created by nf_ct_gre_keymap_add() and the right way
> to destroy it is to call nf_ct_gre_keymap_destroy().

I think you use call nf_ct_iterate_cleanup() to get rid of all GRE
conntrack entries that have a ct->master, which means that they were
created by PPTP. That implicitly calls gre_destroy, which releases the
keymap object.

> This patch marks nf_ct_gre_keymap_flush() as static, so this patch can
> break compilation of third party modules, which use
> nf_ct_gre_keymap_flush. I'm not sure this is the right way to deprecate
> this function.

No problem with that, we don't mind about out of tree modules. With
the approach I'm proposing I think you will also need to make this
function static as it won't be used by PPTP anymore.
