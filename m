From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] tcf_bind_filter failure handling
Date: Mon, 13 Dec 2004 17:53:02 +0100
Message-ID: <20041213165302.GE8493@postel.suug.ch>
References: <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <41917330.6090002@trash.net> <20041212175736.GA8493@postel.suug.ch> <41BC8819.7040501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41BC8819.7040501@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The handling of a failure in tcf_bind_filter is inconsistent.

u32: ignore
fw: ignore
route: ignore
rsvp: ignore
tcindex: error

It might be a good idea to make this consistent. So in order to validate
the classid before making any changes we could simply lock it via get
(see patch below), return an error if it fails  and put it back in case
of an error further in the path or after binding the filter.

Bindings not only locks the class from removal while a filter is
pointing to it. It speeds up classyfing by saving a lookup for every
tc_classify call. It's not really a problem if the class is not locked,
the qdisc will look it up and falls back to a default class if it
doesn't exists so it's rather a cosmetic/policy thing.

Note: The patch below is not intented for inclusion yet and will not
apply since I made local changes to pkt_cls.h.

--- linux-2.6.10-rc3-bk6.orig/include/net/pkt_cls.h	2004-12-12 21:54:03.000000000 +0100
+++ linux-2.6.10-rc3-bk6/include/net/pkt_cls.h	2004-12-13 16:40:06.000000000 +0100
@@ -62,6 +62,18 @@
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
 
+static inline unsigned long
+tcf_class_get(struct tcf_proto *tp, u32 classid)
+{
+	return tp->q->ops->cl_ops->get(tp->q, classid);
+}
+
+static inline void
+tcf_class_put(struct tcf_proto *tp, unsigned long cl)
+{
+	tp->q->ops->cl_ops->put(tp->q, cl);
+}
+
 #ifdef CONFIG_NET_CLS_ACT
 static inline int
 tcf_validate_act_police(struct rtattr *act_police_tlv, struct rtattr *rate_tlv,
