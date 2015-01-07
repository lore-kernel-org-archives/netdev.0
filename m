From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 6/6] openvswitch: Support VXLAN Group Policy extension
Date: Wed, 7 Jan 2015 23:01:55 +0000
Message-ID: <20150107230155.GC21149@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <9c1b0b0acde09019acb61b9b1a4eb4b18c62642a.1420594925.git.tgraf@suug.ch>
 <CAEP_g=__Ssxj3B_0sbp5D+Gh8YmQ7ub9giK4A_QYWVmYctjm-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37995 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbbAGXB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:01:56 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=__Ssxj3B_0sbp5D+Gh8YmQ7ub9giK4A_QYWVmYctjm-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/15 at 02:46pm, Jesse Gross wrote:
> On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > The group policy metadata is handled in the same way as Geneve options
> > and transported as binary blob in a new Netlink attribute
> > OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS which is mutually exclusive to the
> > existing OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS.
> 
> Can you explain some more what the encoding would look like if
> additional options were defined (including ones that are potentially
> mutually exclusive)? The Geneve options are binary but that is coming
> directly from the protocol specification. However, this isn't an on
> the wire format so I'm not sure what it would look like or how it
> would be defined to avoid conflict and allow evolution.

The encoding will be based on struct ovs_vxlan_opts which is extended
as needed by appending new members to the end of the struct. Parsers
will look at the provided length to see which fields are provided.

The user space side looks as follows. I will add similar logic to the
kernel side as soon as we have a 2nd extension.

+/* Returns true if attribute is long enough to cover member of type. */
+#define NL_PROVIDES_MEMBER(attr, type, member, size) \
+       (nl_attr_get_size(attr) >= (offsetof(type, member) + size))
+

[...]

+        case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS: {
+            struct ovs_vxlan_opts *vxlan_opts;
+
+            /* Length verification done per member */
+            vxlan_opts = (struct ovs_vxlan_opts *)nl_attr_get_unspec(a, 0);
+
+            if (NL_PROVIDES_MEMBER(a, struct ovs_vxlan_opts, gbp, sizeof(vxlan_opts->gbp))) {
+                tun->gbp_id = htons(vxlan_opts->gbp & 0xFFFF);
+                tun->gbp_flags = (vxlan_opts->gbp >> 16) & 0xFF;
+            }
+            break;
+        }
