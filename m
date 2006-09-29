From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration
	changes
Date: Fri, 29 Sep 2006 10:08:06 -0400
Message-ID: <200609291008.07290.sgrubb@redhat.com>
References: <20060928180326.896170000@hp.com> <20060928180337.570612000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <linux-audit-bounces@redhat.com>
To: linux-audit@redhat.com
In-Reply-To: <20060928180337.570612000@hp.com>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thursday 28 September 2006 14:03, paul.moore@hp.com wrote:
> This patch adds audit support to NetLabel, including six new audit message
> types shown below.
>
>  #define AUDIT_MAC_UNLBL_ACCEPT 1406
>  #define AUDIT_MAC_UNLBL_DENY   1407
>  #define AUDIT_MAC_CIPSOV4_ADD  1408
>  #define AUDIT_MAC_CIPSOV4_DEL  1409
>  #define AUDIT_MAC_MAP_ADD      1410
>  #define AUDIT_MAC_MAP_DEL      1411
>
> Please consider this for inclusion into 2.6.19.
>
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
>  include/linux/audit.h              |    6 ++
>  include/net/cipso_ipv4.h           |    5 +-
>  include/net/netlabel.h             |    2
>  net/ipv4/cipso_ipv4.c              |    8 ++-
>  net/netlabel/netlabel_cipso_v4.c   |   43 +++++++++++++----
>  net/netlabel/netlabel_domainhash.c |   54 +++++++++++++++++++--
>  net/netlabel/netlabel_domainhash.h |    6 +-
>  net/netlabel/netlabel_mgmt.c       |   14 +++--
>  net/netlabel/netlabel_unlabeled.c  |   36 ++++++++++++--
>  net/netlabel/netlabel_user.c       |   91
> +++++++++++++++++++++++++++++++++++++ net/netlabel/netlabel_user.h       | 
>   6 ++
>  11 files changed, 235 insertions(+), 36 deletions(-)
>
> Index: net-2.6/include/linux/audit.h
> ===================================================================
> --- net-2.6.orig/include/linux/audit.h
> +++ net-2.6/include/linux/audit.h
> @@ -95,6 +95,12 @@
>  #define AUDIT_MAC_POLICY_LOAD	1403	/* Policy file load */
>  #define AUDIT_MAC_STATUS	1404	/* Changed enforcing,permissive,off */
>  #define AUDIT_MAC_CONFIG_CHANGE	1405	/* Changes to booleans */
> +#define AUDIT_MAC_UNLBL_ACCEPT	1406	/* NetLabel: allow unlabeled traffic */ 
> +#define AUDIT_MAC_UNLBL_DENY	1407	/* NetLabel: deny unlabeled traffic */

Please drop the use of DENY per comments later down.

> +#define AUDIT_MAC_CIPSOV4_ADD	1408	/* NetLabel: add CIPSOv4 DOI entry */
> +#define AUDIT_MAC_CIPSOV4_DEL	1409	/* NetLabel: del CIPSOv4 DOI entry */
> +#define AUDIT_MAC_MAP_ADD	1410	/* NetLabel: add LSM domain mapping */  
> +#define AUDIT_MAC_MAP_DEL	1411	/* NetLabel: del LSM domain mapping */
>
>  #define AUDIT_FIRST_KERN_ANOM_MSG   1700
>  #define AUDIT_LAST_KERN_ANOM_MSG    1799
> Index: net-2.6/include/net/cipso_ipv4.h
> ===================================================================
> --- net-2.6.orig/include/net/cipso_ipv4.h
> +++ net-2.6/include/net/cipso_ipv4.h
> @@ -128,7 +128,9 @@ extern int cipso_v4_rbm_strictvalid;
>
>  #ifdef CONFIG_NETLABEL
>  int cipso_v4_doi_add(struct cipso_v4_doi *doi_def);
> -int cipso_v4_doi_remove(u32 doi, void (*callback) (struct rcu_head *
> head)); +int cipso_v4_doi_remove(u32 doi,
> +			u32 audit_secid,
> +			void (*callback) (struct rcu_head * head));
>  struct cipso_v4_doi *cipso_v4_doi_getdef(u32 doi);
>  int cipso_v4_doi_walk(u32 *skip_cnt,
>  		     int (*callback) (struct cipso_v4_doi *doi_def, void *arg),
> @@ -143,6 +145,7 @@ static inline int cipso_v4_doi_add(struc
>  }
>
>  static inline int cipso_v4_doi_remove(u32 doi,
> +				    u32 audit_secid,
>  				    void (*callback) (struct rcu_head * head))
>  {
>  	return 0;
> Index: net-2.6/include/net/netlabel.h
> ===================================================================
> --- net-2.6.orig/include/net/netlabel.h
> +++ net-2.6/include/net/netlabel.h
> @@ -96,7 +96,7 @@
>  struct netlbl_dom_map;
>
>  /* Domain mapping operations */
> -int netlbl_domhsh_remove(const char *domain);
> +int netlbl_domhsh_remove(const char *domain, u32 audit_secid);
>
>  /* LSM security attributes */
>  struct netlbl_lsm_cache {
> Index: net-2.6/net/ipv4/cipso_ipv4.c
> ===================================================================
> --- net-2.6.orig/net/ipv4/cipso_ipv4.c
> +++ net-2.6/net/ipv4/cipso_ipv4.c
> @@ -474,6 +474,7 @@ doi_add_failure_rlock:
>  /**
>   * cipso_v4_doi_remove - Remove an existing DOI from the CIPSO protocol
> engine * @doi: the DOI value
> + * @audit_secid: the LSM secid to use in the audit message
>   * @callback: the DOI cleanup/free callback
>   *
>   * Description:
> @@ -483,7 +484,9 @@ doi_add_failure_rlock:
>   * success and negative values on failure.
>   *
>   */
> -int cipso_v4_doi_remove(u32 doi, void (*callback) (struct rcu_head *
> head)) +int cipso_v4_doi_remove(u32 doi,
> +			u32 audit_secid,
> +			void (*callback) (struct rcu_head * head))
>  {
>  	struct cipso_v4_doi *doi_def;
>  	struct cipso_v4_domhsh_entry *dom_iter;
> @@ -502,7 +505,8 @@ int cipso_v4_doi_remove(u32 doi, void (*
>  		spin_unlock(&cipso_v4_doi_list_lock);
>  		list_for_each_entry_rcu(dom_iter, &doi_def->dom_list, list)
>  			if (dom_iter->valid)
> -				netlbl_domhsh_remove(dom_iter->domain);
> +				netlbl_domhsh_remove(dom_iter->domain,
> +						     audit_secid);
>  		cipso_v4_cache_invalidate();
>  		rcu_read_unlock();
>
> Index: net-2.6/net/netlabel/netlabel_cipso_v4.c
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_cipso_v4.c
> +++ net-2.6/net/netlabel/netlabel_cipso_v4.c
> @@ -32,6 +32,7 @@
>  #include <linux/socket.h>
>  #include <linux/string.h>
>  #include <linux/skbuff.h>
> +#include <linux/audit.h>
>  #include <net/sock.h>
>  #include <net/netlink.h>
>  #include <net/genetlink.h>
> @@ -162,8 +163,7 @@ static int netlbl_cipsov4_add_std(struct
>  	int nla_a_rem;
>  	int nla_b_rem;
>
> -	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
> -	    !info->attrs[NLBL_CIPSOV4_A_TAGLST] ||
> +	if (!info->attrs[NLBL_CIPSOV4_A_TAGLST] ||
>  	    !info->attrs[NLBL_CIPSOV4_A_MLSLVLLST])
>  		return -EINVAL;
>
> @@ -344,8 +344,7 @@ static int netlbl_cipsov4_add_pass(struc
>  	int ret_val;
>  	struct cipso_v4_doi *doi_def = NULL;
>
> -	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
> -	    !info->attrs[NLBL_CIPSOV4_A_TAGLST])
> +	if (!info->attrs[NLBL_CIPSOV4_A_TAGLST])
>  		return -EINVAL;
>
>  	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
> @@ -381,21 +380,35 @@ static int netlbl_cipsov4_add(struct sk_
>
>  {
>  	int ret_val = -EINVAL;
> -	u32 map_type;
> +	u32 type;
> +	u32 doi;
> +	const char *type_str = "(unknown)";
> +	struct audit_buffer *audit_buf;
>
> -	if (!info->attrs[NLBL_CIPSOV4_A_MTYPE])
> +	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
> +	    !info->attrs[NLBL_CIPSOV4_A_MTYPE])
>  		return -EINVAL;
>
> -	map_type = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_MTYPE]);
> -	switch (map_type) {
> +	type = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_MTYPE]);
> +	switch (type) {
>  	case CIPSO_V4_MAP_STD:
> +		type_str = "std";
>  		ret_val = netlbl_cipsov4_add_std(info);
>  		break;
>  	case CIPSO_V4_MAP_PASS:
> +		type_str = "pass";
>  		ret_val = netlbl_cipsov4_add_pass(info);
>  		break;
>  	}
>
> +	if (ret_val == 0) {
> +		doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
> +		audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_ADD,
> +						      NETLINK_CB(skb).sid);
> +		audit_log_format(audit_buf, " doi=%u type=%s", doi, type_str);

type field is already taken for another purpose, it needs to be renamed.

> +		audit_log_end(audit_buf);
> +	}

Normally, we have a field res= that records whether or not the user was 
successful in removing the rule. You would probably do something like 
ret_val==0?1:0 but send a audit event regardless

> +
>  	return ret_val;
>  }
>
> @@ -653,11 +666,21 @@ static int netlbl_cipsov4_listall(struct
>  static int netlbl_cipsov4_remove(struct sk_buff *skb, struct genl_info
> *info) {
>  	int ret_val = -EINVAL;
> -	u32 doi;
> +	u32 doi = 0;
> +	struct audit_buffer *audit_buf;
>
>  	if (info->attrs[NLBL_CIPSOV4_A_DOI]) {
>  		doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
> -		ret_val = cipso_v4_doi_remove(doi, netlbl_cipsov4_doi_free);
> +		ret_val = cipso_v4_doi_remove(doi,
> +					      NETLINK_CB(skb).sid,
> +					      netlbl_cipsov4_doi_free);
> +	}
> +
> +	if (ret_val == 0) {
> +		audit_buf = netlbl_audit_start_common(AUDIT_MAC_CIPSOV4_DEL,
> +						      NETLINK_CB(skb).sid);
> +		audit_log_format(audit_buf, " doi=%u", doi);
> +		audit_log_end(audit_buf);
>  	}

Same as above, global comment about res= being recorded no matter what.

>
>  	return ret_val;
> Index: net-2.6/net/netlabel/netlabel_domainhash.c
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_domainhash.c
> +++ net-2.6/net/netlabel/netlabel_domainhash.c
> @@ -35,12 +35,14 @@
>  #include <linux/skbuff.h>
>  #include <linux/spinlock.h>
>  #include <linux/string.h>
> +#include <linux/audit.h>
>  #include <net/netlabel.h>
>  #include <net/cipso_ipv4.h>
>  #include <asm/bug.h>
>
>  #include "netlabel_mgmt.h"
>  #include "netlabel_domainhash.h"
> +#include "netlabel_user.h"
>
>  struct netlbl_domhsh_tbl {
>  	struct list_head *tbl;
> @@ -186,6 +188,7 @@ int netlbl_domhsh_init(u32 size)
>  /**
>   * netlbl_domhsh_add - Adds a entry to the domain hash table
>   * @entry: the entry to add
> + * @audit_secid: the LSM secid to use in the audit message
>   *
>   * Description:
>   * Adds a new entry to the domain hash table and handles any updates to
> the @@ -193,10 +196,12 @@ int netlbl_domhsh_init(u32 size)
>   * negative on failure.
>   *
>   */
> -int netlbl_domhsh_add(struct netlbl_dom_map *entry)
> +int netlbl_domhsh_add(struct netlbl_dom_map *entry, u32 audit_secid)
>  {
>  	int ret_val;
>  	u32 bkt;
> +	struct audit_buffer *audit_buf;
> +	char *audit_domain;
>
>  	switch (entry->type) {
>  	case NETLBL_NLTYPE_UNLABELED:
> @@ -236,6 +241,26 @@ int netlbl_domhsh_add(struct netlbl_dom_
>  		spin_unlock(&netlbl_domhsh_def_lock);
>  	} else
>  		ret_val = -EINVAL;
> +	if (ret_val == 0) {
> +		if (entry->domain != NULL)
> +			audit_domain = entry->domain;
> +		else
> +			audit_domain = "(default)";
> +		audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_ADD,
> +						      audit_secid);
> +		audit_log_format(audit_buf, " domain=%s", audit_domain);
> +		switch (entry->type) {
> +		case NETLBL_NLTYPE_UNLABELED:
> +			audit_log_format(audit_buf, " protocol=unlbl");
> +			break;
> +		case NETLBL_NLTYPE_CIPSOV4:
> +			audit_log_format(audit_buf,
> +					 " protocol=cipsov4 doi=%u",
> +					 entry->type_def.cipsov4->doi);
> +			break;
> +		}
> +		audit_log_end(audit_buf);
> +	}
>  	rcu_read_unlock();
>
>  	if (ret_val != 0) {
> @@ -254,6 +279,7 @@ int netlbl_domhsh_add(struct netlbl_dom_
>  /**
>   * netlbl_domhsh_add_default - Adds the default entry to the domain hash
> table * @entry: the entry to add
> + * @audit_secid: the LSM secid to use in the audit message
>   *
>   * Description:
>   * Adds a new default entry to the domain hash table and handles any
> updates @@ -261,14 +287,15 @@ int netlbl_domhsh_add(struct netlbl_dom_
>   * negative on failure.
>   *
>   */
> -int netlbl_domhsh_add_default(struct netlbl_dom_map *entry)
> +int netlbl_domhsh_add_default(struct netlbl_dom_map *entry, u32
> audit_secid) {
> -	return netlbl_domhsh_add(entry);
> +	return netlbl_domhsh_add(entry, audit_secid);
>  }
>
>  /**
>   * netlbl_domhsh_remove - Removes an entry from the domain hash table
>   * @domain: the domain to remove
> + * @audit_secid: the LSM secid to use in the audit message
>   *
>   * Description:
>   * Removes an entry from the domain hash table and handles any updates to
> the @@ -276,10 +303,12 @@ int netlbl_domhsh_add_default(struct net
>   * negative on failure.
>   *
>   */
> -int netlbl_domhsh_remove(const char *domain)
> +int netlbl_domhsh_remove(const char *domain, u32 audit_secid)
>  {
>  	int ret_val = -ENOENT;
>  	struct netlbl_dom_map *entry;
> +	struct audit_buffer *audit_buf;
> +	char *audit_domain;
>
>  	rcu_read_lock();
>  	if (domain != NULL)
> @@ -316,8 +345,18 @@ int netlbl_domhsh_remove(const char *dom
>  			ret_val = -ENOENT;
>  		spin_unlock(&netlbl_domhsh_def_lock);
>  	}
> -	if (ret_val == 0)
> +	if (ret_val == 0) {
> +		if (entry->domain != NULL)
> +			audit_domain = entry->domain;
> +		else
> +			audit_domain = "(default)";
> +		audit_buf = netlbl_audit_start_common(AUDIT_MAC_MAP_DEL,
> +						      audit_secid);
> +		audit_log_format(audit_buf, " domain=%s", audit_domain);
> +		audit_log_end(audit_buf);
> +
>  		call_rcu(&entry->rcu, netlbl_domhsh_free_entry);
> +	}
>
>  remove_return:
>  	rcu_read_unlock();
> @@ -326,6 +365,7 @@ remove_return:
>
>  /**
>   * netlbl_domhsh_remove_default - Removes the default entry from the table
> + * @audit_secid: the LSM secid to use in the audit message
>   *
>   * Description:
>   * Removes/resets the default entry for the domain hash table and handles
> any @@ -333,9 +373,9 @@ remove_return:
>   * success, non-zero on failure.
>   *
>   */
> -int netlbl_domhsh_remove_default(void)
> +int netlbl_domhsh_remove_default(u32 audit_secid)
>  {
> -	return netlbl_domhsh_remove(NULL);
> +	return netlbl_domhsh_remove(NULL, audit_secid);
>  }
>
>  /**
> Index: net-2.6/net/netlabel/netlabel_domainhash.h
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_domainhash.h
> +++ net-2.6/net/netlabel/netlabel_domainhash.h
> @@ -57,9 +57,9 @@ struct netlbl_dom_map {
>  int netlbl_domhsh_init(u32 size);
>
>  /* Manipulate the domain hash table */
> -int netlbl_domhsh_add(struct netlbl_dom_map *entry);
> -int netlbl_domhsh_add_default(struct netlbl_dom_map *entry);
> -int netlbl_domhsh_remove_default(void);
> +int netlbl_domhsh_add(struct netlbl_dom_map *entry, u32 audit_secid);
> +int netlbl_domhsh_add_default(struct netlbl_dom_map *entry, u32
> audit_secid); +int netlbl_domhsh_remove_default(u32 audit_secid);
>  struct netlbl_dom_map *netlbl_domhsh_getentry(const char *domain);
>  int netlbl_domhsh_walk(u32 *skip_bkt,
>  		     u32 *skip_chain,
> Index: net-2.6/net/netlabel/netlabel_mgmt.c
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_mgmt.c
> +++ net-2.6/net/netlabel/netlabel_mgmt.c
> @@ -108,7 +108,7 @@ static int netlbl_mgmt_add(struct sk_buf
>
>  	switch (entry->type) {
>  	case NETLBL_NLTYPE_UNLABELED:
> -		ret_val = netlbl_domhsh_add(entry);
> +		ret_val = netlbl_domhsh_add(entry, NETLINK_CB(skb).sid);
>  		break;
>  	case NETLBL_NLTYPE_CIPSOV4:
>  		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
> @@ -125,7 +125,7 @@ static int netlbl_mgmt_add(struct sk_buf
>  			rcu_read_unlock();
>  			goto add_failure;
>  		}
> -		ret_val = netlbl_domhsh_add(entry);
> +		ret_val = netlbl_domhsh_add(entry, NETLINK_CB(skb).sid);
>  		rcu_read_unlock();
>  		break;
>  	default:
> @@ -161,7 +161,7 @@ static int netlbl_mgmt_remove(struct sk_
>  		return -EINVAL;
>
>  	domain = nla_data(info->attrs[NLBL_MGMT_A_DOMAIN]);
> -	return netlbl_domhsh_remove(domain);
> +	return netlbl_domhsh_remove(domain, NETLINK_CB(skb).sid);
>  }
>
>  /**
> @@ -277,7 +277,8 @@ static int netlbl_mgmt_adddef(struct sk_
>
>  	switch (entry->type) {
>  	case NETLBL_NLTYPE_UNLABELED:
> -		ret_val = netlbl_domhsh_add_default(entry);
> +		ret_val = netlbl_domhsh_add_default(entry,
> +						    NETLINK_CB(skb).sid);
>  		break;
>  	case NETLBL_NLTYPE_CIPSOV4:
>  		if (!info->attrs[NLBL_MGMT_A_CV4DOI])
> @@ -294,7 +295,8 @@ static int netlbl_mgmt_adddef(struct sk_
>  			rcu_read_unlock();
>  			goto adddef_failure;
>  		}
> -		ret_val = netlbl_domhsh_add_default(entry);
> +		ret_val = netlbl_domhsh_add_default(entry,
> +						    NETLINK_CB(skb).sid);
>  		rcu_read_unlock();
>  		break;
>  	default:
> @@ -322,7 +324,7 @@ adddef_failure:
>   */
>  static int netlbl_mgmt_removedef(struct sk_buff *skb, struct genl_info
> *info) {
> -	return netlbl_domhsh_remove_default();
> +	return netlbl_domhsh_remove_default(NETLINK_CB(skb).sid);
>  }
>
>  /**
> Index: net-2.6/net/netlabel/netlabel_unlabeled.c
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_unlabeled.c
> +++ net-2.6/net/netlabel/netlabel_unlabeled.c
> @@ -64,6 +64,27 @@ static struct nla_policy netlbl_unlabel_
>  };
>
>  /*
> + * Helper Functions
> + */
> +
> +/**
> + * netlbl_unlabel_acceptflg_set - Set the unlabeled accept flag
> + * @value: desired value
> + * @audit_secid: the LSM secid to use in the audit message
> + *
> + * Description:
> + * Set the value of the unlabeled accept flag to @value.
> + *
> + */
> +static void netlbl_unlabel_acceptflg_set(u8 value, u32 audit_secid)
> +{
> +	atomic_set(&netlabel_unlabel_accept_flg, value);
> +	netlbl_audit_nomsg((value ?
> +			    AUDIT_MAC_UNLBL_ACCEPT : AUDIT_MAC_UNLBL_DENY),
> +			   audit_secid);

Looking at how this is being used, I think only 1 message type should be used. 
There are places in the audit system where we set a flag to 1 or 0, but only 
have 1 message type. We record the old and new value. So, you'd need to pass 
that to the logger.

> +}
> +
> +/*
>   * NetLabel Command Handlers
>   */
>
> @@ -79,18 +100,18 @@ static struct nla_policy netlbl_unlabel_
>   */
>  static int netlbl_unlabel_accept(struct sk_buff *skb, struct genl_info
> *info) {
> -	int ret_val = -EINVAL;
>  	u8 value;
>
>  	if (info->attrs[NLBL_UNLABEL_A_ACPTFLG]) {
>  		value = nla_get_u8(info->attrs[NLBL_UNLABEL_A_ACPTFLG]);
>  		if (value == 1 || value == 0) {
> -			atomic_set(&netlabel_unlabel_accept_flg, value);
> -			ret_val = 0;
> +			netlbl_unlabel_acceptflg_set(value,
> +						     NETLINK_CB(skb).sid);
> +			return 0;
>  		}
>  	}
>
> -	return ret_val;
> +	return -EINVAL;
>  }
>
>  /**
> @@ -229,16 +250,19 @@ int netlbl_unlabel_defconf(void)
>  {
>  	int ret_val;
>  	struct netlbl_dom_map *entry;
> +	u32 secid;
> +
> +	security_task_getsecid(current, &secid);
>
>  	entry = kzalloc(sizeof(*entry), GFP_KERNEL);
>  	if (entry == NULL)
>  		return -ENOMEM;
>  	entry->type = NETLBL_NLTYPE_UNLABELED;
> -	ret_val = netlbl_domhsh_add_default(entry);
> +	ret_val = netlbl_domhsh_add_default(entry, secid);
>  	if (ret_val != 0)
>  		return ret_val;
>
> -	atomic_set(&netlabel_unlabel_accept_flg, 1);
> +	netlbl_unlabel_acceptflg_set(1, secid);
>
>  	return 0;
>  }
> Index: net-2.6/net/netlabel/netlabel_user.c
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_user.c
> +++ net-2.6/net/netlabel/netlabel_user.c
> @@ -32,6 +32,9 @@
>  #include <linux/types.h>
>  #include <linux/list.h>
>  #include <linux/socket.h>
> +#include <linux/audit.h>
> +#include <linux/tty.h>
> +#include <linux/security.h>
>  #include <net/sock.h>
>  #include <net/netlink.h>
>  #include <net/genetlink.h>
> @@ -74,3 +77,91 @@ int netlbl_netlink_init(void)
>
>  	return 0;
>  }
> +
> +/*
> + * NetLabel Audit Functions
> + */
> +
> +/**
> + * netlbl_audit_start_common - Start an audit message
> + * @type: audit message type
> + * @secid: LSM context ID
> + *
> + * Description:
> + * Start an audit message using the type specified in @type and fill the
> audit + * message with some fields common to all NetLabel audit messages. 
> Returns + * a pointer to the audit buffer on success, NULL on failure.
> + *
> + */
> +struct audit_buffer *netlbl_audit_start_common(int type, u32 secid)
> +{

Generally, logging functions are moved into auditsc.c where the context and 
other functions are defined. 

> +	struct audit_context *audit_ctx = current->audit_context;
> +	struct audit_buffer *audit_buf;
> +	uid_t audit_loginuid;
> +	const char *audit_tty;
> +	char audit_comm[sizeof(current->comm)];
> +	struct vm_area_struct *vma;
> +	char *secctx;
> +	u32 secctx_len;
> +
> +	audit_buf = audit_log_start(audit_ctx, GFP_ATOMIC, type);
> +	if (audit_buf == NULL)
> +		return NULL;
> +
> +	audit_loginuid = audit_get_loginuid(audit_ctx);

Netlink is async protocol, you should use the loginuid of the netlink packet 
and pass it into this function.

> +	if (current->signal &&
> +	    current->signal->tty &&
> +	    current->signal->tty->name)
> +		audit_tty = current->signal->tty->name;
> +	else
> +		audit_tty = "(none)";

Netlink is an async protocol. How do you know that the sender is current? This 
is a global comment, please check use of current everywhere.

> +	get_task_comm(audit_comm, current);
> +
> +	audit_log_format(audit_buf,
> +			 "netlabel: auid=%u uid=%u tty=%s pid=%d",
> +			 audit_loginuid,
> +			 current->uid,
> +			 audit_tty,
> +			 current->pid);

Why are you logging all this? When we add audit rules, all that we log is the 
auid, and subj. If we need to log all this, we should probably have a helper 
function that gets called by other config change loggers.

> +	audit_log_format(audit_buf, " comm=");
> +	audit_log_untrustedstring(audit_buf, audit_comm);
> +	if (current->mm) {
> +		down_read(&current->mm->mmap_sem);
> +		vma = current->mm->mmap;
> +		while (vma) {
> +			if ((vma->vm_flags & VM_EXECUTABLE) &&
> +			    vma->vm_file) {
> +				audit_log_d_path(audit_buf,
> +						 " exe=",
> +						 vma->vm_file->f_dentry,
> +						 vma->vm_file->f_vfsmnt);
> +				break;
> +			}
> +			vma = vma->vm_next;
> +		}
> +		up_read(&current->mm->mmap_sem);
> +	}
> +

If this function was moved inside auditsc.c you could use a function there 
that does this. But the question remains why all this data?

> +	if (secid != 0 &&
> +	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0)
> +		audit_log_format(audit_buf, " subj=%s", secctx);
> +
> +	return audit_buf;
> +}
> +
> +/**
> + * netlbl_audit_nomsg - Send an audit message without additional text
> + * @type: audit message type
> + * @secid: LSM context ID
> + *
> + * Description:
> + * Send an audit message with only the common NetLabel audit fields.
> + *
> + */
> +void netlbl_audit_nomsg(int type, u32 secid)
> +{
> +	struct audit_buffer *audit_buf;
> +
> +	audit_buf = netlbl_audit_start_common(type, secid);
> +	audit_log_end(audit_buf);

We normally record old and new value when changing flags like this.

> +}
> Index: net-2.6/net/netlabel/netlabel_user.h
> ===================================================================
> --- net-2.6.orig/net/netlabel/netlabel_user.h
> +++ net-2.6/net/netlabel/netlabel_user.h
> @@ -34,6 +34,7 @@
>  #include <linux/types.h>
>  #include <linux/skbuff.h>
>  #include <linux/capability.h>
> +#include <linux/audit.h>
>  #include <net/netlink.h>
>  #include <net/genetlink.h>
>  #include <net/netlabel.h>
> @@ -75,4 +76,9 @@ static inline void *netlbl_netlink_hdr_p
>
>  int netlbl_netlink_init(void);
>
> +/* NetLabel Audit Functions */
> +
> +struct audit_buffer *netlbl_audit_start_common(int type, u32 secid);
> +void netlbl_audit_nomsg(int type, u32 secid);
> +
>  #endif
>
> --
> paul moore
> linux security @ hp
>
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit
