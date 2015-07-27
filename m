From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: netns refcnt leak for kernel accept sock
Date: Mon, 27 Jul 2015 20:19:46 +0200
Message-ID: <20150727181946.GJ16447@oracle.com>
References: <20150727142146.GC16447@oracle.com>
 <CAHA+R7Pe08rfERd1rMR1Y_kK2iUm4TDc92rRhhJhr-e+_fsioA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46578 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbbG0ST7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:19:59 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7Pe08rfERd1rMR1Y_kK2iUm4TDc92rRhhJhr-e+_fsioA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (07/27/15 11:13), Cong Wang wrote:
> 
> That refcnt should be released in sock destructor too, when the tcp
> connection is terminated.

yes, but in my case, the listen socket is opened as part of
the ->init indirection in pernet_operations (thus it is a kernel socket)
and the expectation is that this listen socket, and any accept sockets
derived from it, will be closed in ->exit.

But if the accept socket is treated as a uspace socket (thus holds a get_net())
then it will block cleanup_net() and the associated ->exit cleanup operations.

This is probably not a problem for other systems like vxlan/gue/geneve etc
because they all use udp sockets, thus dont have the "accept" equivalent.

But fundamentally, its wrong for a kspace listen socket to result in a
"uspace" accept socket.

> Given the fact that sk_destruct() checks for sk_net_refcnt, your
> patch makes sense to me. But I am not sure how a TCP kernel
> socket is supposed to use.

Thanks for the confirmation - I think RDS is a bit of a maverick here in
that it uses tcp sockets unlike vxlan etc.
For those curious about RDS-TCP, I've actually updated the documentation at
https://oss.oracle.com/projects/rds/dist/documentation/rds-3.1-spec.html
recently. I hope that helps.

--Sowmini
