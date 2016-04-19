From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 13:48:16 +0300
Message-ID: <CANUX_P2VS73zSk-hgommRtrbhj1DD6iZYps=AELGqXaOGUK0cA@mail.gmail.com>
References: <1461015356.10638.124.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160418.205755.87909888849343438.davem@davemloft.net>
	<20160418.214851.122286645854721047.davem@davemloft.net>
	<20160418.235207.395468709808133833.davem@davemloft.net>
	<1461060543.2766.20.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	roopa@cumulusnetworks.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36173 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbcDSKsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 06:48:17 -0400
Received: by mail-io0-f173.google.com with SMTP id u185so13606487iod.3
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 03:48:17 -0700 (PDT)
In-Reply-To: <1461060543.2766.20.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 1:09 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Mon, 2016-04-18 at 23:52 -0400, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Mon, 18 Apr 2016 21:48:51 -0400 (EDT)
>>
>> > I think the time has probably come to have a new netlink attribute
>> > format that doesn't have this multi-decade old problem.
>>  ...
>>
>> Scratch this whole idea, I think the padding attribute works a lot
>> better and is backwards compatible with every properly written
>> netlink application.
>
> This talk about attribute flags reminded me about something else.
>
> At netconf, we talked about how awkward it can be that one doesn't know
> if an attribute was accepted by the kernel or simply ignored because
> it's not supported (older kernel version).
>
> I considered (and Emmanuel has started to cook up a patch for it)
> adding a flag here meaning "reject if not parsed" (or so).
>
> Now, I realize that with all the existing netlink commands one can't
> actually rely on that (since it requires some infrastructure), but new
> commands in existing families and also entirely new generic netlink
> families would allow let userspace rely on such a thing.
>
> Thoughts?


FWIW:

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 2a5dbcc..2dfd46d 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -663,6 +663,15 @@ static inline int nla_type(const struct nlattr *nla)
 }

 /**
+ * nla_must_parse - returns true if the attribute must be parsed
+ * @nla: netlink attribute
+ */
+static inline bool nla_must_parse(const struct nlattr *nla)
+{
+       return nla->nla_type & NLA_F_NET_MUST_PARSE;
+}
+
+/**
  * nla_data - head of payload
  * @nla: netlink attribute
  */
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 1a85940..e81a8d4 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -165,17 +165,21 @@ struct nlattr {

 /*
  * nla_type (16 bits)
- * +---+---+-------------------------------+
- * | N | O | Attribute Type                |
- * +---+---+-------------------------------+
+ * +---+---+---+----------------------------+
+ * | N | O | M | Attribute Type             |
+ * +---+---+---+----------------------------+
  * N := Carries nested attributes
  * O := Payload stored in network byte order
+ * M := Attribute can't be ignored
  *
  * Note: The N and O flag are mutually exclusive.
  */
 #define NLA_F_NESTED           (1 << 15)
 #define NLA_F_NET_BYTEORDER    (1 << 14)
-#define NLA_TYPE_MASK          ~(NLA_F_NESTED | NLA_F_NET_BYTEORDER)
+#define NLA_F_NET_MUST_PARSE   (1 << 13)
+#define NLA_TYPE_MASK          ~(NLA_F_NESTED |        \
+                                 NLA_F_NET_BYTEORDER | \
+                                 NLA_F_NET_MUST_PARSE)

 #define NLA_ALIGNTO            4
 #define NLA_ALIGN(len)         (((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
diff --git a/lib/nlattr.c b/lib/nlattr.c
index f5907d2..fa15e6f 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -198,6 +198,10 @@ int nla_parse(struct nlattr **tb, int maxtype,
const struct nlattr *head,
                        }

                        tb[type] = (struct nlattr *)nla;
+               } else if (nla_must_parse(nla)) {
+                       err = -EINVAL;
+                       goto errout;
                }
        }
