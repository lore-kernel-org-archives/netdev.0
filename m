From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 0/3] Send audit/procinfo/cgroup data in socket-level
	control message
Date: Wed, 04 Sep 2013 08:30:21 -0700
Message-ID: <1378308621.7360.110.camel@edumazet-glaptop>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1378275261-4553-1-git-send-email-jkaluza@redhat.com>
	<878uzdf2xp.fsf@xmission.com>
	<20130904145830.GC28517@madcap2.tricolour.ca>
	<20130904152022.GD28517@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130904152022.GD28517-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-04 at 11:20 -0400, Richard Guy Briggs wrote:
> On Wed, Sep 04, 2013 at 10:58:30AM -0400, Richard Guy Briggs wrote:
> > On Wed, Sep 04, 2013 at 12:42:26AM -0700, Eric W. Biederman wrote:
> > > Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > > > this patchset against net-next (applies also to linux-next) adds 3 new types
> > > > of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).
> > 
> > > By my count you have overflowed cb in struct sk_buff and are stomping on
> > > _skb_refdest.
> > 
> > For patch1/3 I count 56/48, then for patch3 I get 48/48.  Jan, you might
> > do the conversion to a pointer in patch1/3 to avoid bisect breakage.
> 
> Wait, that __aligned(8) is for cb[48], not for the contents.
> 
> For patch1/3 I count 28/48 on 32-bit, 36/48 on 64-bit (or would that be
> 56 by default on 64-bit arches without aligned specified?), then for
> patch3 I get 24/48 on 32 and 40/48 on 64 (or again 48/48 by default?).

Do not count, just add this :

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 86de99a..5b61320 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1329,6 +1329,7 @@ static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 {
 	int i;
 
+	BUILD_BUG_ON(sizeof(struct unix_skb_parms) > sizeof(skb->cb));
 	scm->fp = UNIXCB(skb).fp;
 	UNIXCB(skb).fp = NULL;
