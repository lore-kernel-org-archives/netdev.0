From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Re: [PATCH] ti: Remove no longer used functions and prototypes in
 the files, cpsw_ale.c and cpsw_ale.h
Date: Fri, 29 May 2015 14:53:47 -0400
Message-ID: <20150529185347.GJ6169@csclub.uwaterloo.ca>
References: <1432917117-23446-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mugunthanvnm@ti.com,
	prabhakar.csengg@gmail.com, arnd@arndb.de, m-karicheri2@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.csclub.uwaterloo.ca ([129.97.134.52]:52164 "EHLO
	mail.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432AbbE2TDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 15:03:35 -0400
Content-Disposition: inline
In-Reply-To: <1432917117-23446-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 12:31:57PM -0400, Nicholas Krause wrote:
> This removes the function, cpsw_ale_flush and its prototype from the
> files cpsw_ale.c and cpsw_ale.h due to having no more callers. Finally
> we also remove the functions, cpsw_ale_set_vlan_entry, 
> cpsw_ale_flush_ucast and cpsw_ale_add_ucast and their prototypes
> due to their only caller being removed with the removal of the
> function, cpsw_ale.c respectfully.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/ti/cpsw_ale.c | 162 -------------------------------------
>  drivers/net/ethernet/ti/cpsw_ale.h |   3 -
>  2 files changed, 165 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
> index 6e927b4..b360dc8 100644
> --- a/drivers/net/ethernet/ti/cpsw_ale.c
> +++ b/drivers/net/ethernet/ti/cpsw_ale.c
> @@ -147,27 +147,6 @@ static int cpsw_ale_write(struct cpsw_ale *ale, int idx, u32 *ale_entry)
>  	return idx;
>  }
>  
> -static int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
> -{
> -	u32 ale_entry[ALE_ENTRY_WORDS];
> -	int type, idx;
> -
> -	for (idx = 0; idx < ale->params.ale_entries; idx++) {
> -		u8 entry_addr[6];
> -
> -		cpsw_ale_read(ale, idx, ale_entry);
> -		type = cpsw_ale_get_entry_type(ale_entry);
> -		if (type != ALE_TYPE_ADDR && type != ALE_TYPE_VLAN_ADDR)
> -			continue;
> -		if (cpsw_ale_get_vlan_id(ale_entry) != vid)
> -			continue;
> -		cpsw_ale_get_addr(ale_entry, entry_addr);
> -		if (ether_addr_equal(entry_addr, addr))
> -			return idx;
> -	}
> -	return -ENOENT;
> -}
> -
>  static int cpsw_ale_match_vlan(struct cpsw_ale *ale, u16 vid)
>  {
>  	u32 ale_entry[ALE_ENTRY_WORDS];
> @@ -268,147 +247,6 @@ int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid)
>  }
>  EXPORT_SYMBOL_GPL(cpsw_ale_flush_multicast);
>  
> -static void cpsw_ale_flush_ucast(struct cpsw_ale *ale, u32 *ale_entry,
> -				 int port_mask)
> -{
> -	int port;
> -
> -	port = cpsw_ale_get_port_num(ale_entry);
> -	if ((BIT(port) & port_mask) == 0)
> -		return; /* ports dont intersect, not interested */
> -	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
> -}
> -
> -int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask)
> -{
> -	u32 ale_entry[ALE_ENTRY_WORDS];
> -	int ret, idx;
> -
> -	for (idx = 0; idx < ale->params.ale_entries; idx++) {
> -		cpsw_ale_read(ale, idx, ale_entry);
> -		ret = cpsw_ale_get_entry_type(ale_entry);
> -		if (ret != ALE_TYPE_ADDR && ret != ALE_TYPE_VLAN_ADDR)
> -			continue;
> -
> -		if (cpsw_ale_get_mcast(ale_entry))
> -			cpsw_ale_flush_mcast(ale, ale_entry, port_mask);
> -		else
> -			cpsw_ale_flush_ucast(ale, ale_entry, port_mask);
> -
> -		cpsw_ale_write(ale, idx, ale_entry);
> -	}
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(cpsw_ale_flush);
> -
> -static inline void cpsw_ale_set_vlan_entry_type(u32 *ale_entry,
> -						int flags, u16 vid)
> -{
> -	if (flags & ALE_VLAN) {
> -		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
> -		cpsw_ale_set_vlan_id(ale_entry, vid);
> -	} else {
> -		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
> -	}
> -}
> -
> -int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
> -		       int flags, u16 vid)
> -{
> -	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
> -	int idx;
> -
> -	cpsw_ale_set_vlan_entry_type(ale_entry, flags, vid);
> -
> -	cpsw_ale_set_addr(ale_entry, addr);
> -	cpsw_ale_set_ucast_type(ale_entry, ALE_UCAST_PERSISTANT);
> -	cpsw_ale_set_secure(ale_entry, (flags & ALE_SECURE) ? 1 : 0);
> -	cpsw_ale_set_blocked(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
> -	cpsw_ale_set_port_num(ale_entry, port);
> -
> -	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
> -	if (idx < 0)
> -		idx = cpsw_ale_match_free(ale);
> -	if (idx < 0)
> -		idx = cpsw_ale_find_ageable(ale);
> -	if (idx < 0)
> -		return -ENOMEM;
> -
> -	cpsw_ale_write(ale, idx, ale_entry);
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(cpsw_ale_add_ucast);
> -
> -int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
> -		       int flags, u16 vid)
> -{
> -	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
> -	int idx;
> -
> -	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
> -	if (idx < 0)
> -		return -ENOENT;
> -
> -	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
> -	cpsw_ale_write(ale, idx, ale_entry);
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(cpsw_ale_del_ucast);
> -
> -int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
> -		       int flags, u16 vid, int mcast_state)
> -{
> -	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
> -	int idx, mask;
> -
> -	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
> -	if (idx >= 0)
> -		cpsw_ale_read(ale, idx, ale_entry);
> -
> -	cpsw_ale_set_vlan_entry_type(ale_entry, flags, vid);
> -
> -	cpsw_ale_set_addr(ale_entry, addr);
> -	cpsw_ale_set_super(ale_entry, (flags & ALE_BLOCKED) ? 1 : 0);
> -	cpsw_ale_set_mcast_state(ale_entry, mcast_state);
> -
> -	mask = cpsw_ale_get_port_mask(ale_entry);
> -	port_mask |= mask;
> -	cpsw_ale_set_port_mask(ale_entry, port_mask);
> -
> -	if (idx < 0)
> -		idx = cpsw_ale_match_free(ale);
> -	if (idx < 0)
> -		idx = cpsw_ale_find_ageable(ale);
> -	if (idx < 0)
> -		return -ENOMEM;
> -
> -	cpsw_ale_write(ale, idx, ale_entry);
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(cpsw_ale_add_mcast);
> -
> -int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
> -		       int flags, u16 vid)
> -{
> -	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
> -	int idx;
> -
> -	idx = cpsw_ale_match_addr(ale, addr, (flags & ALE_VLAN) ? vid : 0);
> -	if (idx < 0)
> -		return -EINVAL;
> -
> -	cpsw_ale_read(ale, idx, ale_entry);
> -
> -	if (port_mask)
> -		cpsw_ale_set_port_mask(ale_entry, port_mask);
> -	else
> -		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_FREE);
> -
> -	cpsw_ale_write(ale, idx, ale_entry);
> -	return 0;
> -}
> -EXPORT_SYMBOL_GPL(cpsw_ale_del_mcast);
> -
>  int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
>  		      int reg_mcast, int unreg_mcast)
>  {
> diff --git a/drivers/net/ethernet/ti/cpsw_ale.h b/drivers/net/ethernet/ti/cpsw_ale.h
> index af1e7ec..85a0fcf 100644
> --- a/drivers/net/ethernet/ti/cpsw_ale.h
> +++ b/drivers/net/ethernet/ti/cpsw_ale.h
> @@ -91,10 +91,7 @@ void cpsw_ale_start(struct cpsw_ale *ale);
>  void cpsw_ale_stop(struct cpsw_ale *ale);
>  
>  int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout);
> -int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask);
>  int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid);
> -int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
> -		       int flags, u16 vid);
>  int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
>  		       int flags, u16 vid);
>  int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,

So now there is a cpsw_ale_del_ucast but no cpsw_ale_add_ucast?
That makes no sense.  There are a lot of abilities in the ALE that
the current driver isn't using, but which someone might want to use,
and having the functions there could be very handy.

Also many of these are exported symbols, perhaps some currently out of
tree code is using them.  No idea.

This seems like a remove unused code just for the sake of doing something
change.  I am not convinced.

-- 
Len Sorensen
