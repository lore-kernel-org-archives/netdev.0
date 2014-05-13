From: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
Subject: Re: [PATCH net-next 4/5] ieee802154: don't
 ignore "to" argument in unbound dgram sendmsg
Date: Tue, 13 May 2014 17:13:40 -0300
Message-ID: <20140513201340.GB12817@ws>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1400001846-5349-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1400001846-5349-5-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Phoebe Buckheister wrote:
> For some reason, unconnected 802.15.4 dgram sockets ignore the destination
> argument of sendmsg(), while bound sockets use it. Instead, send packets
> to the destination given by the user, and default to the connected
> destination only if no explicit target is given.

We discussed this a bit on IRC. Here's what I think happened and what
happens with your patch. Before:

conn'ed	msg_nam	action
-------	-------	------------------------------------------
no	no	send to initialization value (= broadcast)
no	yes	idem
yes	no	send to connected address
yes	yes	idem

After your patch:

conn'ed	msg_nam	action
-------	-------	------------------------------------------
no	no	send to initialization value (= broadcast)
no	yes	send to msg_name
yes	no	send to connected address
yes	yes	send to msg_name

This is certainly more correct. Blurting out a broadcast in the
no/no case isn't nice, though. It would be better to return either
ENOTCONN (POSIX [1]) or (even better, according to GNU libc [2])
EDESTADDRREQ.

POSIX [1] says we may get EISCONN in the yes/yes case and the Linux
man page [3] says we either get EISCONN or the msg_name argument is
ignored. So that also doesn't look quite right yet.

- Werner

[1] http://pubs.opengroup.org/onlinepubs/007904975/
[2] http://www.gnu.org/software/libc/manual/html_node/Error-Codes.html
[3] man sendmsg

------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
