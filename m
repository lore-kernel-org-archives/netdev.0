From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK) interface. (v3)
Date: Thu, 24 Dec 2009 14:51:19 +0900
Message-ID: <200912240551.nBO5pKMx082156@www262.sakura.ne.jp>
References: <20091224014454.GA24161@heat> <m2pr653s1l.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	herbert@gondor.apana.org.au, Valdis.Kletnieks@vt.edu,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, michael@laptop.org
To: sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <m2pr653s1l.fsf@ssh.synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Samir Bellabes wrote:
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index f2f842d..0c65c55 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1402,6 +1402,8 @@ struct task_struct {
> >   	unsigned int sessionid;
> >   #endif
> >   	seccomp_t seccomp;
> > +/* Flags for limiting networking via prctl(PR_SET_NETWORK). */
> > +  unsigned long network;
> >   
> >   /* Thread group tracking */
> >      	u32 parent_exec_id;
> 
> I think this is unnecessary, as LSM module, you should use the
> void* security member of the structure cred. 
> 
> this member allows you to mark task_struct as you which, it's a kind of
> abstraction provided to all security modules.

I want to use per task_struct variable. Since cred is copy-on-write, we have to
use kmalloc()/kfree() whenever we modify variable in cred. That introduces
unnwanted error paths (i.e. memory allocation failure) and overhead.

Old version of TOMOYO had similar mechanism that allows userland programs to
disable specific operations (disable chroot(), disable execve(), disable
mount() etc. ; which is different from POSIX capabilities).
I added "unsigned int dropped_capability;" to task_struct for implementing it.
Adding variables to task_struct makes it possible to error-path-free.
I prefer adding "void *security;" to task_struct which is duplicated upon fork() and
released upon exit().
