From: Julian Anastasov <ja@ssi.bg>
Subject: Re: UDP sockets bound to ANY send answers with wrong src ip address
Date: Fri, 11 Jun 2004 16:53:35 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0406111651370.2763-100000@l>
References: <200406111527.45955.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	<yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>, <davem@redhat.com>,
	<pekkas@netcore.fi>, <jmorris@redhat.com>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200406111527.45955.vda@port.imtp.ilyichevsk.odessa.ua>
List-Id: netdev.vger.kernel.org


	Hello,

On Fri, 11 Jun 2004, Denis Vlasenko wrote:

> Hmmm... do I have to set a *routing dest address* field
> to set src ip address of my UDP packet?

	Try such function:

static int my_send(int fd, unsigned srcip, (struct sockaddr *) remote,
			char *data, int len)
{
	struct iovec iov = { data, len };
	struct {
		struct cmsghdr cm;
		struct in_pktinfo ipi;
	} cmsg = {
		.cm = {
			.cmsg_len	= sizeof(struct cmsghdr) +
						sizeof(struct in_pktinfo),
			.cmsg_level	= SOL_IP,
			.cmsg_type	= IP_PKTINFO,
		},
		.ipi = {
			.ipi_ifindex	= 0,
			.ipi_spec_dst	= srcip,
		},
	};
	struct msghdr m = {
		.msg_name	= remote,
		.msg_namelen	= sizeof(struct sockaddr_in),
		.msg_iov	= &iov,
		.msg_iovlen	= 1,
		.msg_control	= &cmsg,
		.msg_controllen	= sizeof(cmsg),
		.msg_flags	= 0,
	};

	return sendmsg(fd, &m, MSG_NOSIGNAL|MSG_DONTWAIT);
}

Regards

--
Julian Anastasov <ja@ssi.bg>

