From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: Drop linux/socket.h
Date: Fri, 16 Aug 2013 12:50:12 +0300
Message-ID: <20130816095012.GA21547@redhat.com>
References: <1376536816-10951-1-git-send-email-asias@redhat.com>
	<20130815.140740.1781732332793977170.davem@davemloft.net>
	<20130816012743.GA5944@hj.localdomain>
	<20130816.003159.2033932881805410431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130816.003159.2033932881805410431.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 16, 2013 at 12:31:59AM -0700, David Miller wrote:
> From: Asias He <asias@redhat.com>
> Date: Fri, 16 Aug 2013 09:27:43 +0800
> 
> > On Thu, Aug 15, 2013 at 02:07:40PM -0700, David Miller wrote:
> >> From: Asias He <asias@redhat.com>
> >> Date: Thu, 15 Aug 2013 11:20:16 +0800
> >> 
> >> > memcpy_fromiovec is moved to lib/iovec.c. No need to include
> >> > linux/socket.h for it.
> >> > 
> >> > Signed-off-by: Asias He <asias@redhat.com>
> >> 
> >> You can't do this.
> >> 
> >> Because this file doesn't include the header file that
> >> provides the declaration, which is linux/uio.h
> > 
> > vhost.c includes drivers/vhost/vhost.h. In drivers/vhost/vhost.h, we
> > have linux/uio.h included.
> 
> Nothing in vhost.h needs linux/uio.h right?  That's very poor style,
> include the header where the dependency exists which is vhost.c

It needs struct iovec, which is in include/uapi/linux/uio.h.
Do you think it's better to include uapi/linux/uio.h directly?
In that case maybe we should update linux/socket.h
to pull in uapi/linux/uio.h directly too.

Or even just forward-declare struct iovec.
I tried this last option and the only fall-out seems to be in security/
- though I didn't do an allyes config build yet.  Good idea? If yes let
me know and I'll do that.

-->

socket: forward-declare struct iovec

We can simplify header dependencies by using a forward declaration
of struct iovec in socket.h - it's always used through a pointer there.
Do this and fix up users that rely on socket.h including uio.h.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 230c04b..3ad6f52 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -4,7 +4,6 @@
 
 #include <asm/socket.h>			/* arch-dependent defines	*/
 #include <linux/sockios.h>		/* the SIOCxxx I/O controls	*/
-#include <linux/uio.h>			/* iovec support		*/
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 #include <uapi/linux/socket.h>
@@ -44,6 +43,8 @@ struct linger {
  *	belong in an obscure libc emulation or the bin.
  */
  
+struct iovec;
+
 struct msghdr {
 	void	*	msg_name;	/* Socket name			*/
 	int		msg_namelen;	/* Length of name		*/
diff --git a/security/keys/compat.c b/security/keys/compat.c
index d65fa7f..9c2723f 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -13,6 +13,7 @@
 #include <linux/keyctl.h>
 #include <linux/compat.h>
 #include <linux/slab.h>
+#include <uapi/linux/uio.h>
 #include "internal.h"
 
 /*


-- 
MST
