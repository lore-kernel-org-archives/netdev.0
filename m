From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next v5 4/5] netlink: pass extended ACK struct to
 parsing functions
Date: Wed, 12 Apr 2017 15:56:08 +0200
Message-ID: <20170412135608.GG1952@nanopsycho>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-5-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170412123408.22012-5-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Wed, Apr 12, 2017 at 02:34:07PM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org wrote:
>From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
>Pass the new extended ACK reporting struct to all of the
>generic netlink parsing functions. For now, pass NULL in
>almost all callers (except for some in the core.)
>
>Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>---

[...]

>diff --git a/lib/nlattr.c b/lib/nlattr.c
>index b42b8577fc23..a7e0b16078df 100644
>--- a/lib/nlattr.c
>+++ b/lib/nlattr.c
>@@ -112,6 +112,7 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
>  * @len: length of attribute stream
>  * @maxtype: maximum attribute type to be expected
>  * @policy: validation policy
>+ * @extack: extended ACK report struct
>  *
>  * Validates all attributes in the specified attribute stream against the
>  * specified policy. Attributes with a type exceeding maxtype will be
>@@ -120,20 +121,23 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
>  * Returns 0 on success or a negative error code.
>  */
> int nla_validate(const struct nlattr *head, int len, int maxtype,
>-		 const struct nla_policy *policy)
>+		 const struct nla_policy *policy,
>+		 struct netlink_ext_ack *extack)
> {
> 	const struct nlattr *nla;
>-	int rem, err;
>+	int rem;
> 
> 	nla_for_each_attr(nla, head, len, rem) {
>-		err = validate_nla(nla, maxtype, policy);
>-		if (err < 0)
>-			goto errout;
>+		int err = validate_nla(nla, maxtype, policy);
>+
>+		if (err < 0) {

		You can just check:
	 	if (err)
		while you are at it. validate_nla never returns positive
		value.

Btw, unrelated to this patch, I find it odd to have 2 functions:
nla_validate
validate_nla
Confusing :)


>+			if (extack)
>+				extack->bad_attr = nla;
>+			return err;
>+		}
> 	}
> 
>-	err = 0;
>-errout:
>-	return err;
>+	return 0;
> }
> EXPORT_SYMBOL(nla_validate);
> 
>@@ -180,7 +184,8 @@ EXPORT_SYMBOL(nla_policy_len);
>  * Returns 0 on success or a negative error code.
>  */
> int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
>-	      int len, const struct nla_policy *policy)
>+	      int len, const struct nla_policy *policy,
>+	      struct netlink_ext_ack *extack)
> {
> 	const struct nlattr *nla;
> 	int rem, err;
>@@ -193,8 +198,11 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
> 		if (type > 0 && type <= maxtype) {
> 			if (policy) {
> 				err = validate_nla(nla, maxtype, policy);
>-				if (err < 0)
>+				if (err < 0) {

Same here.



>+					if (extack)
>+						extack->bad_attr = nla;
> 					goto errout;
>+				}
> 			}
> 
> 			tb[type] = (struct nlattr *)nla;
