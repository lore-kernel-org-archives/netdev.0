From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/1] RFC: poll/select performance on datagram sockets
Date: Sat, 30 Oct 2010 15:17:58 +0200
Message-ID: <1288444678.2680.966.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <20101030123403.5e01540d@chocolatine.cbg.collabora.co.uk>
	 <1288443217.2680.962.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>,
	Davide Libenzi <davidel@xmailserver.org>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55034 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab0J3NSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 09:18:06 -0400
In-Reply-To: <1288443217.2680.962.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Problem is the peer_wait, that epoll doesnt seem to be plugged into.
> 
> Bug is in unix_dgram_poll()
> 
> It calls sock_poll_wait( ... &unix_sk(other)->peer_wait,) only if socket
> is 'writable'. Its a clear bug
> 
> Try this patch please ?
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 0ebc777..315716c 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2092,7 +2092,7 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
>  
>  	/* writable? */
>  	writable = unix_writable(sk);
> -	if (writable) {
> +	if (1 /*writable*/) {
>  		other = unix_peer_get(sk);
>  		if (other) {
>  			if (unix_peer(other) != sk) {
> 
> 
> 

Also you'll need to change your program to make the epoll registrations
_after_ sockets connect(), or else you can see that epoll() wont know
about the other peer stuff.

for (i = 0 ; i < NB_CLIENTS ; i++) {
	client_fds[i] = socket(AF_UNIX, SOCK_DGRAM, 0);
}


for (i = 0 ; i < NB_CLIENTS ; i++) {
	connect(client_fds[i], (struct sockaddr*)&addr_server, sizeof(addr_server));
}

ev.events = EPOLLOUT;
ev.data.fd = client_fds[NB_CLIENTS-1];
if (epoll_ctl(epollfd, EPOLL_CTL_ADD, client_fds[NB_CLIENTS-1], &ev) == -1) {
      perror("epoll_ctl: client_fds max");
      exit(EXIT_FAILURE);
}
if (trigger == 0) {
      ev.events = EPOLLOUT;
      ev.data.fd = client_fds[0];
      if (epoll_ctl(epollfd, EPOLL_CTL_ADD, client_fds[0], &ev) == -1) {
        perror("epoll_ctl: client_fds 0");
        exit(EXIT_FAILURE);
      }
}



