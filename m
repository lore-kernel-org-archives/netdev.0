From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] remove lots of IS_ERR_VALUE abuses
Date: Fri, 27 May 2016 14:46:05 -0700
Message-ID: <20160527144605.f2a52ea02cad1297ff188691@linux-foundation.org>
References: <1464384685-347275-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Airlie <airlied-cv59FeDIM0c@public.gmane.org>, "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andrzej Hajda <a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Srinivas Kandagatla <srinivas.kandagatla-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bob Peterson <rpeterso-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1464384685-347275-1-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 27 May 2016 23:23:25 +0200 Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:

> Most users of IS_ERR_VALUE() in the kernel are wrong, as they
> pass an 'int' into a function that takes an 'unsigned long'
> argument. This happens to work because the type is sign-extended
> on 64-bit architectures before it gets converted into an
> unsigned type.
> 
> However, anything that passes an 'unsigned short' or 'unsigned int'
> argument into IS_ERR_VALUE() is guaranteed to be broken, as are
> 8-bit integers and types that are wider than 'unsigned long'.
> 
> Andrzej Hajda has already fixed a lot of the worst abusers that
> were causing actual bugs, but it would be nice to prevent any
> users that are not passing 'unsigned long' arguments.
> 
> This patch changes all users of IS_ERR_VALUE() that I could find
> on 32-bit ARM randconfig builds and x86 allmodconfig. For the
> moment, this doesn't change the definition of IS_ERR_VALUE()
> because there are probably still architecture specific users
> elsewhere.

So you do plan to add some sort of typechecking into IS_ERR_VALUE()?

> Almost all the warnings I got are for files that are better off
> using 'if (err)' or 'if (err < 0)'.
> The only legitimate user I could find that we get a warning for
> is the (32-bit only) freescale fman driver, so I did not remove
> the IS_ERR_VALUE() there but changed the type to 'unsigned long'.
> For 9pfs, I just worked around one user whose calling conventions
> are so obscure that I did not dare change the behavior.
> 
> I was using this definition for testing:
> 
>  #define IS_ERR_VALUE(x) ((unsigned long*)NULL == (typeof (x)*)NULL && \
>        unlikely((unsigned long long)(x) >= (unsigned long long)(typeof(x))-MAX_ERRNO))
> 
> which ends up making all 16-bit or wider types work correctly with
> the most plausible interpretation of what IS_ERR_VALUE() was supposed
> to return according to its users, but also causes a compile-time
> warning for any users that do not pass an 'unsigned long' argument.
> 
> I suggested this approach earlier this year, but back then we ended
> up deciding to just fix the users that are obviously broken. After
> the initial warning that caused me to get involved in the discussion
> (fs/gfs2/dir.c) showed up again in the mainline kernel, Linus
> asked me to send the whole thing again.
