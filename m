From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: USO v2, Scatter-gather approach
Date: Tue, 19 Jul 2005 14:23:20 -0700 (PDT)
Message-ID: <20050719.142320.52167011.davem@davemloft.net>
References: <20050603004106.BAB6A7B990@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, raghavendra.koushik@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <20050603004106.BAB6A7B990@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: ravinandan.arakali@neterion.com
Date: Thu,  2 Jun 2005 17:41:06 -0700 (PDT)

> Attached below is version 2 of kernel patch for UDP Large send offload 
> feature. This patch uses the "Scatter-Gather" approach.
> It also incorporates David Miller's comments on the first version.

I've reviewed this patches, and I think there is a problem
with the sock_append_data() scheme.  You disallow the case
where there is an SKB on the write queue already.

This breaks NFS, and other things using MSG_MORE and UDP_CORK.
They do a two step packet building:

1) Send protocol headers, f.e. NFS

2) Send file contents via sendfile()

3) Uncork socket so packet gets emitted

and due to this check:

+	if (skb_queue_len(&sk->sk_write_queue)) {
+		*err = -EOPNOTSUPP;
+		return NULL;
+	}

you end up not supporting this correctly.

So we have two options, either add support for corked socket
handling to sock_append_data() or we go with the frag_list
patch which doesn't have this problem.

I prefer the frag_list patch from a cleanliness perspective,
however I remember you saying that the sock_append_data()
approach obtained better performance.  And that seems clear
since there will be less TX descriptors needed to send such
frames unless the driver does coalescing as it walks the
frag_list chain.
