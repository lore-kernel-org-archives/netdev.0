From: Lars Ellenberg <lars.ellenberg-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 0/8] netlink: align attributes when
 needed (patchset #3)
Date: Tue, 26 Apr 2016 13:54:27 +0200
Message-ID: <20160426115427.GB20950@soda.linbit>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, sd-y1jBWg8GRStKuXlAQpz2QA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, jack-IBi9RG/b67k@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, philipp.reisner-63ez5xqkn6DQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461657978-13360-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.linbit.com/mailman/options/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linbit.com/pipermail/drbd-dev>
List-Post: <mailto:drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org>
List-Help: <mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=help>
List-Subscribe: <http://lists.linbit.com/mailman/listinfo/drbd-dev>,
	<mailto:drbd-dev-request-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org?subject=subscribe>
Sender: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
Errors-To: drbd-dev-bounces-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 26, 2016 at 10:06:10AM +0200, Nicolas Dichtel wrote:
> 
> This is the continuation (series #3) of the work done to align netlink
> attributes when these attributes contain some 64-bit fields.
> 
> It's the last patchset from what I've seen.
> 
> The last user of nla_put_u64() is block/drbd. This module does not use
> standard netlink API (see all the stuff in include/linux/genl_magic_struct.h
> and include/linux/genl_magic_func.h). I didn't modify it because it's seems
> hard to do it whithout testing and fully understanding the context

Something like this should just work.

diff --git a/include/linux/genl_magic_struct.h b/include/linux/genl_magic_struct.h
index eecd19b..5715dac 100644
--- a/include/linux/genl_magic_struct.h
+++ b/include/linux/genl_magic_struct.h
@@ -80,7 +80,7 @@ extern void CONCAT_(GENL_MAGIC_FAMILY, _genl_unregister)(void);
 			nla_get_u32, nla_put_u32, true)
 #define __u64_field(attr_nr, attr_flag, name)	\
 	__field(attr_nr, attr_flag, name, NLA_U64, __u64, \
-			nla_get_u64, nla_put_u64, false)
+			nla_get_u64, nla_put_u64_64bit_unspec, false)
 #define __str_field(attr_nr, attr_flag, name, maxlen) \
 	__array(attr_nr, attr_flag, name, NLA_NUL_STRING, char, maxlen, \
 			nla_strlcpy, nla_put, false)
diff --git a/include/net/netlink.h b/include/net/netlink.h
index e589cb3..38ba770 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -871,6 +871,18 @@ static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
 }
 
 /**
+ * nla_put_u64_64bit_unspec - nla_put_u64_64bit() with padattr = 0
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ */
+static inline int nla_put_u64_64bit_unspec(struct sk_buff *skb, int attrtype,
+				    u64 value)
+{
+	return nla_put_64bit(skb, attrtype, sizeof(u64), &value, NLA_UNSPEC);
+}
+
+/**
  * nla_put_be64 - Add a __be64 netlink attribute to a socket buffer and align it
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type

> (for
> example, why include/linux/drbd_genl.h is not part of uapi?).
> Any thoughts?

probably should be.

Thanks,

    Lars
