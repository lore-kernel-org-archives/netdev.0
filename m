From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message size
 properly
Date: Wed, 31 Mar 2010 20:21:17 +0200
Message-ID: <20100331182116.GB2822@psychotron.redhat.com>
References: <20100331151102.GB8043@psychotron.lab.eng.brq.redhat.com>
 <4BB38A8A.9050501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, davem@davemloft.net,
	Krzysztof Oledzki <ole@ans.pl>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BB38A8A.9050501@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Mar 31, 2010 at 07:46:50PM CEST, kaber@trash.net wrote:
>Jiri Pirko wrote:
>> Message size should be dependent on net->ct.sysctl_acct, not on
>> CONFIG_NF_CT_ACCT definition.
>
>Krzysztof actually wanted to get rid of the config option entirely
>some time ago, but at that time there were some (now solved) problems
>that prevented his. I've CCed him, hoping that this will finally
>get completed :)
>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> 
>> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
>> index 569410a..2b0cfa4 100644
>> --- a/net/netfilter/nf_conntrack_netlink.c
>> +++ b/net/netfilter/nf_conntrack_netlink.c
>> @@ -426,6 +426,19 @@ ctnetlink_proto_size(const struct nf_conn *ct)
>>  }
>>  
>>  static inline size_t
>> +ctnetlink_counters_size(const struct nf_conn *ct)
>> +{
>> +	struct net *net = nf_ct_net(ct);
>> +
>> +	if (!net->ct.sysctl_acct)
>> +		return 0;
>> +	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
>> +	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
>> +	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
>> +	       ;
>
>This is also not fully correct since the sysctl only affects newly
>created conntracks, existing ones still have counters that are dumped.
>I'd suggest to simple check whether the conntrack has an accounting
>extension.

Okay, I see your point. How about this:

Subject: [net-next-2.6 PATCH] netfilter: ctnetlink: compute message size properly V2

Message size should be dependent on net->ct.sysctl_acct, not on
CONFIG_NF_CT_ACCT definition.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 569410a..44487d8 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -426,6 +426,17 @@ ctnetlink_proto_size(const struct nf_conn *ct)
 }
 
 static inline size_t
+ctnetlink_counters_size(const struct nf_conn *ct)
+{
+	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
+		return 0;
+	return 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
+	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
+	       ;
+}
+
+static inline size_t
 ctnetlink_nlmsg_size(const struct nf_conn *ct)
 {
 	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
@@ -435,11 +446,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
-#ifdef CONFIG_NF_CT_ACCT
-	       + 2 * nla_total_size(0) /* CTA_COUNTERS_ORIG|REPL */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_PACKETS */
-	       + 2 * nla_total_size(sizeof(uint64_t)) /* CTA_COUNTERS_BYTES */
-#endif
+	       + ctnetlink_counters_size(ct)
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
 	       + nla_total_size(0) /* CTA_PROTOINFO */
 	       + nla_total_size(0) /* CTA_HELP */
