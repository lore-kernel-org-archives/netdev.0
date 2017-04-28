From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] samples/bpf: Add support for SKB_MODE to xdp1
 and xdp_tx_iptunnel
Date: Fri, 28 Apr 2017 23:40:35 +0200
Message-ID: <20170428234035.5f0beec6@redhat.com>
References: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, ast@fb.com,
        daniel@iogearbox.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53546 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1422932AbdD1Vkl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 17:40:41 -0400
In-Reply-To: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Apr 2017 09:11:13 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add option to xdp1 and xdp_tx_iptunnel to insert xdp program in
> SKB_MODE:
>  - update set_link_xdp_fd to take a flags argument that is added to the
>    RTM_SETLINK message
> 
>  - Add -S option to xdp1 and xdp_tx_iptunnel user code. When passed in
>    XDP_FLAGS_SKB_MODE is set in the flags arg passed to set_link_xdp_fd
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Thanks, this will make is a lot easier to measure the overhead of the
network stack compared to XDP, like I did here:
 http://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html

[...]
> diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
> index 0d449d8032d1..d4433a47e6c3 100644
> --- a/samples/bpf/bpf_load.c
> +++ b/samples/bpf/bpf_load.c
> @@ -563,7 +563,7 @@ struct ksym *ksym_search(long key)
>  	return &syms[0];
>  }
>  
> -int set_link_xdp_fd(int ifindex, int fd)
> +int set_link_xdp_fd(int ifindex, int fd, int flags)

Shouldn't the flags be a unsigned int, actually a __u32 ?

>  {
>  	struct sockaddr_nl sa;
>  	int sock, seq = 0, len, ret = -1;
> @@ -599,15 +599,28 @@ int set_link_xdp_fd(int ifindex, int fd)
>  	req.nh.nlmsg_seq = ++seq;
>  	req.ifinfo.ifi_family = AF_UNSPEC;
>  	req.ifinfo.ifi_index = ifindex;
> +
> +	/* started nested attribute for XDP */
>  	nla = (struct nlattr *)(((char *)&req)
>  				+ NLMSG_ALIGN(req.nh.nlmsg_len));
>  	nla->nla_type = NLA_F_NESTED | 43/*IFLA_XDP*/;
> +	nla->nla_len = NLA_HDRLEN;
>  
> -	nla_xdp = (struct nlattr *)((char *)nla + NLA_HDRLEN);
> +	/* add XDP fd */
> +	nla_xdp = (struct nlattr *)((char *)nla + nla->nla_len);
>  	nla_xdp->nla_type = 1/*IFLA_XDP_FD*/;
>  	nla_xdp->nla_len = NLA_HDRLEN + sizeof(int);
>  	memcpy((char *)nla_xdp + NLA_HDRLEN, &fd, sizeof(fd));
> -	nla->nla_len = NLA_HDRLEN + nla_xdp->nla_len;
> +	nla->nla_len += nla_xdp->nla_len;
> +
> +	/* if user passed in any flags, add those too */
> +	if (flags) {
> +		nla_xdp = (struct nlattr *)((char *)nla + nla->nla_len);
> +		nla_xdp->nla_type = 3/*IFLA_XDP_FLAGS*/;
> +		nla_xdp->nla_len = NLA_HDRLEN + sizeof(flags);
> +		memcpy((char *)nla_xdp + NLA_HDRLEN, &flags, sizeof(flags));
> +		nla->nla_len += nla_xdp->nla_len;
> +	}
>  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
