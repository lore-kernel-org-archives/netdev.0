From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: 32bit compat for rtnetlink wireless extensions?
Date: Mon, 27 Mar 2006 10:42:43 -0800
Message-ID: <20060327184242.GC31478@bougret.hpl.hp.com>
References: <200603261408.48766.arnd@arndb.de>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750832AbWC0Smu@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200603261408.48766.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 26, 2006 at 02:08:48PM +0200, Arnd Bergmann wrote:
> I stumbled over the 'WE-20 for kernel 2.6.16' and afaict, there is no
> way that IW_HEADER_TYPE_POINT rtnetlink messages can work when using
> 32 bit user tools on a 64 bit kernel.

	Please check again ;-) I agree that it's not obvious...

> For the ioctl inteface, this gets handled using the do_wireless_ioctl
> function in fs/compat_ioctl.c, but we don't have a way to convert
> netlink data -- it is supposed to always be compatible between
> 32 and 64 bit.
> 
> What is the reason for having IW_HEADER_TYPE_POINT in the first place?
> Does that reason apply to both the ioctl and the netlink interface, or
> can the netlink transport for wireless commands be changed so it
> does not need user space pointers?

	Actually, when things are passed over RtNetlink, the pointer
is removed, and the content of IW_HEADER_TYPE_POINT is moved to not
leave a gap.
	The actual code for the commands is a little bit complex,
especially that the buffer is "optimised". But, if you check for the
comments, you will find it. Instead, you may want to check the code
for the event, where I do the same, and which is easier to read.
	The function is iwe_stream_add_point(), and you will find it
in include/net/iw_handler.h. Copy below...

	I was toying with the idea of changing the
IW_HEADER_TYPE_POINT struct itself, but I discarded that because the
amount of fixing in the driver that would require.

> 	Arnd <><

	Thanks for the quick review, have fun...

	Jean

/*------------------------------------------------------------------*/
/*
 * Wrapper to add an short Wireless Event containing a pointer to a
 * stream of events.
 */
static inline char *
iwe_stream_add_point(char *	stream,		/* Stream of events */
		     char *	ends,		/* End of stream */
		     struct iw_event *iwe,	/* Payload length + flags */
		     char *	extra)		/* More payload */
{
	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
	/* Check if it's possible */
	if(likely((stream + event_len) < ends)) {
		iwe->len = event_len;
		memcpy(stream, (char *) iwe, IW_EV_LCP_LEN);
		memcpy(stream + IW_EV_LCP_LEN,
		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
		       IW_EV_POINT_LEN - IW_EV_LCP_LEN);
		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
		stream += event_len;
	}
	return stream;
}
