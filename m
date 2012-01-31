From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 10:50:57 -0800
Message-ID: <1328035857.6911.8.camel@joe2Laptop>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
	 <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
	 <20120131181554.GA24397@dev3310.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>, christoph.paasch@uclouvain.be
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120131181554.GA24397@dev3310.snc6.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-31 at 10:15 -0800, Arun Sharma wrote:
> On Mon, Jan 30, 2012 at 08:22:03PM -0800, Bjorn Helgaas wrote:
> > > We print a different message depending on whether we're out
> > > of TCP memory or there are too many orphan sockets.
> > 
> > This patch mentions pairs of messages that are almost the same, but
> > not quite.  If they're supposed to be different, I'd suggest making
> > them clearly different.  As it is, the differences look like careless
> > mistakes:
> 
> Good point. Updated patch changes the existing printks to be
> the same as well.
[]
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
[]
> @@ -2014,11 +2014,24 @@ adjudge_to_death:
[]
> +		if (too_many_orphans) {
>  			if (net_ratelimit())
> -				printk(KERN_INFO "TCP: too many of orphaned "
> +				printk(KERN_INFO "TCP: too many orphaned "
>  				       "sockets\n");
> +		}
> +
> +		if (out_of_socket_memory) {
> +			if (net_ratelimit())
> +				printk(KERN_INFO "TCP: out of memory. "
> +				       "Consider tuning tcp_mem\n");
> +		}
> +
[]
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
[]
> @@ -77,9 +78,14 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
[]
> +	too_many_orphans = tcp_too_many_orphans(sk, shift);
> +	out_of_socket_memory = tcp_out_of_memory(sk);
> +	if (too_many_orphans || out_of_socket_memory) {
> +		if (out_of_socket_memory && net_ratelimit())
> +			printk(KERN_INFO "TCP: out of memory. "
> +					 "Consider tuning tcp_mem\n");
> +		if (too_many_orphans && net_ratelimit())
> +			printk(KERN_INFO "TCP: too many orphaned sockets\n");

These 2 blocks emit the messages in different order.

It might be useful to use a generic routine.

void tcp_log_oom(bool orphans, bool socket_memory)
{
	if (!net_ratelimit())
		return;
	if (orphans)
		pr_info("too many orphaned sockets\n");
	if (socket_memory)
		pr_info("out of socket memory - consider tuning tcp_mem\n");
}
