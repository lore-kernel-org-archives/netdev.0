From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/1] hv_sock: implements Hyper-V transport
 for Virtual Sockets (AF_VSOCK)
Date: Thu, 24 Aug 2017 18:19:31 -0700 (PDT)
Message-ID: <20170824.181931.584865895464286033.davem@davemloft.net>
References: <KL1P15301MB0008D0FB2F8F5B90E7737C3CBF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhansen@vmware.com, stefanha@redhat.com, netdev@vger.kernel.org,
        mkubecek@suse.cz, joe@perches.com, olaf@aepfle.de,
        sthemmin@microsoft.com, jasowang@redhat.com, kys@microsoft.com,
        haiyangz@microsoft.com, dave.scott@docker.com,
        linux-kernel@vger.kernel.org, apw@canonical.com,
        rolf.neugebauer@docker.com, gregkh@linuxfoundation.org,
        marcelo.cerri@canonical.com, devel@linuxdriverproject.org,
        vkuznets@redhat.com, georgezhang@vmware.com,
        dan.carpenter@oracle.com, acking@vmware.com, dtor@vmware.com,
        grantr@vmware.com, cavery@redhat.com
To: decui@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59700 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753838AbdHYBTd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 21:19:33 -0400
In-Reply-To: <KL1P15301MB0008D0FB2F8F5B90E7737C3CBF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dexuan Cui <decui@microsoft.com>
Date: Wed, 23 Aug 2017 04:52:14 +0000

> +#define VMBUS_PKT_TRAILER	(sizeof(u64))

This is not the packet trailer, it's the size of the packet trailer.
Please make this macro name match more accurately what it is.

> +	/* Have we sent the zero-length packet (FIN)? */
> +	unsigned long fin_sent;

Why does this need to be atomic?  Why can't a smaller simpler
mechanism be used to make sure hvs_shutdown() only performs
hvs_send_data() call once on the channel?

> +static inline bool is_valid_srv_id(const uuid_le *id)
> +{
> +	return !memcmp(&id->b[4], &srv_id_template.b[4], sizeof(uuid_le) - 4);
> +}

Do not use the inline function attribute in *.c code.  Let the
compiler decide.

> +static inline unsigned int get_port_by_srv_id(const uuid_le *svr_id)

Likewise.

> +static inline void hvs_addr_init(struct sockaddr_vm *addr,

Likewise.

> +static inline void hvs_remote_addr_init(struct sockaddr_vm *remote,
> +					struct sockaddr_vm *local)

Likewise.

And so on and so forth, please audit this for your entire patch.

> +	*((u32 *)&h->vm_srv_id) = vsk->local_addr.svm_port;
> +	*((u32 *)&h->host_srv_id) = vsk->remote_addr.svm_port;

There has to be a better way to express this.

And if this is partially initializing vm_srv_id, at a minimum
endianness needs to be taken into account.
