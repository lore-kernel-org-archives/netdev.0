From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Tue, 6 Jul 2004 13:24:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706132426.097f71e6.davem@redhat.com>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
	<20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, acme@conectiva.com.br, netdev@oss.sgi.com,
        alessandro.suardi@oracle.com, phyprabab@yahoo.com,
        linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 11:47:41 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The problem is that when
> we propose window scaling, we expect that the other side receives the same initial
> SYN request that we sent.  If there is corrupting firewalls that strip it then
> the window we send is not correctly scaled; so the other side thinks there is not
> enough space to send.

Inaccurate analysis Stephen.

If the window option is edited out from the SYN by the firewall,
it is impossible for the receiving system to respond with any
window scaling option in the SYN+ACK packet.

If a window scale option is not present in the SYN, it means that
it does not support window scaling at all.

What must be really happening, therefore, is that the firewall is
patching the scale factor in the option, not deleting it outright.
And then it isn't properly rescaling the window field in the TCP
headers for the rest of the connection's lifetime.  That would explain
all of this.

We can confirm this by getting a trace at both ends of a sick connection,
and seeing if a non-zero window scale option gets patched to some other
value by the time it reaches the receiving system.

Then we will be aware of two bugs:

1) Cisco IOS, when NAT'ing, can mis-adjust SACK block options such
   that the sequence numbers are corrupt.

2) Some firewalls patch non-zero window scale options to be zero ones
   yet do not properly adjust the window field in TCP headers for the
   rest of the connection.
