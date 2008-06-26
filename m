From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP MD5 and socket accept
Date: Thu, 26 Jun 2008 14:33:58 -0700
Message-ID: <20080626143358.53fa9117@extreme>
References: <20080625225657.61e1b29b@extreme>
	<396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"=?UTF-8?B?5ZCJ6Jek6Iux5piO?=" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35932 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbYFZVeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 17:34:05 -0400
In-Reply-To: <396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jun 2008 07:46:59 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> On Wed, Jun 25, 2008 at 10:56 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > What will break if tcp_create_openreq_child was fixed to copy md5_info if
> > present?
> >
> > This all comes about because right now using Quagga a Linux to Linux
> > works with TCP MD5. But a Linux to Cisco connection fails if using
> > TCP MD5.
> 
> I'll have a look at this later today but, as you say, Linux to Linux
> works, and getting the key wrong certainly breaks it (and without
> setsockopt on the child, I believe). So some MD5 information is
> getting copied from listening sockets to children.
> 
> Also note the MD5 on Linux is pretty badly broken in the face of
> packet loss at the moment. I have patches floating around to fix it,
> but not in any trees yet.
> 
> 
> AGL
> 

The problem is that md5 calculation assumes that the data buffer is
linear! It doesn't handle any kind of scatter-gather in skb!

int tcp_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
		      int bplen,
		      struct tcphdr *th, unsigned int tcplen,
		      struct tcp_md5sig_pool *hp)
{
...
	/* 3. The TCP segment data (if any) */
	data_len = tcplen - (th->doff << 2);
	if (data_len > 0) {
		u8 *data = (u8 *)th + (th->doff << 2);
		sg_set_buf(&sg[block++], data, data_len);
		nbytes += data_len;
	}

This is wrong, it needs to handle fragmented skb's.  I'll work out a patch
but it means passing skb to calc_md5_hash or just turn off using scatter/gather
on MD5 connections.
