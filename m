From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: sctp bug: sk_ack_backlog wrap-around problem
Date: Tue, 10 Jun 2014 07:33:42 -0400
Message-ID: <20140610113342.GC6275@hmsreliant.think-freely.org>
References: <CA+=dFzg6gXDTXr6AusZ40_swrjQa-yoS1YLv3=SJAjKYgKzrbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	xufeng zhang <xufeng.zhang@windriver.com>
To: Xufeng Zhang <xufengzhang.main@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+=dFzg6gXDTXr6AusZ40_swrjQa-yoS1YLv3=SJAjKYgKzrbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2014 at 02:27:07PM +0800, Xufeng Zhang wrote:
> Hi Vlad and Neil,
> 
> I found a sk_ack_backlog wrap-around problem during handling received
> COOKIE_ECHO.
> 
> Consider the scenario:
> For a TCP-style socket, while processing the COOKIE_ECHO chunk in
> sctp_sf_do_5_1D_ce(),
> after it has passed a series of sanity check, a new association would
> be created in
> sctp_unpack_cookie(), but afterwards, some processing maybe failed,
> and sctp_association_free()
> will be called to free the previously allocated association, in
> sctp_association_free(),
> sk_ack_backlog value is decremented for this socket, since the initial
> value for sk_ack_backlog is 0,
> after the decrement, it will be 65535, a wrap-around problem happens,
> and if we want to establish
> new associations afterward in the same socket, ABORT would be
> triggered since sctp deem the
> accept queue as full.
> 
> Do you have any idea to fix such kind of issue?
> 

first thought would be to traverse the list of associations on the endpoint in
sctp_association_free if its a tcp style socket, and then only decrement the
backlog if we find the association being freed on the list.  By doing that we
can be confident that we've increased the backlog via sctp_endpoint_add_asoc.

Best
Neil

> Thanks a lot!
> Xufeng
> 
