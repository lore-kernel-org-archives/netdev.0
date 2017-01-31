From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Tue, 31 Jan 2017 19:14:12 +0100
Message-ID: <20170131181411.cq3o7yxrnhq6thpt@dhcp-1-212.brq.redhat.com>
References: <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk>
 <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk>
 <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
 <20170126232912.rgh6undqxd4tofqj@dhcp-1-212.brq.redhat.com>
 <CAM_iQpXqqmAGPbo6jNJV4bOco9sfvXukNAxYPp4tfL=CNwF-RA@mail.gmail.com>
 <20170127064143.ddyt43iglu2odlld@dhcp-1-212.brq.redhat.com>
 <CAM_iQpWSRjh4sV-hQxSAFsmvXZ1P4u959vm+UfCP55szQUb0-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpWSRjh4sV-hQxSAFsmvXZ1P4u959vm+UfCP55szQUb0-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2017 at 10:44:03PM -0800, Cong Wang wrote:
> On Thu, Jan 26, 2017 at 10:41 PM, Mateusz Guzik <mguzik@redhat.com> wrote:
> > On Thu, Jan 26, 2017 at 09:11:07PM -0800, Cong Wang wrote:
> >> On Thu, Jan 26, 2017 at 3:29 PM, Mateusz Guzik <mguzik@redhat.com> wrote:
> >> > Currently the file creation is potponed until unix_bind can no longer
> >> > fail otherwise. With it reordered, it may be someone races you with a
> >> > different path and now you are left with a file to clean up. Except it
> >> > is quite unclear for me if you can unlink it.
> >>
> >> What races do you mean here? If you mean someone could get a
> >> refcount of that file, it could happen no matter we have bindlock or not
> >> since it is visible once created. The filesystem layer should take care of
> >> the file refcount so all we need to do here is calling path_put() as in my
> >> patch. Or if you mean two threads calling unix_bind() could race without
> >> binlock, only one of them should succeed the other one just fails out.
> >
> > Two threads can race and one fails with EINVAL.
> >
> > With your patch there is a new file created and it is unclear what to
> > do with it - leaving it as it is sounds like the last resort and
> > unlinking it sounds extremely fishy as it opens you to games played by
> > the user.
> 
> But the file is created and visible to users too even without my patch,
> the file is also put when the unix sock is released. So the only difference
> my patch makes is bindlock is no longer taken during file creation, which
> does not seem to be the cause of the problem you complain here.
> 
> Mind being more specific?

Consider 2 threads which bind the same socket, but with different paths.

Currently exactly one file will get created, the one used to bind.

With your patch both threads can succeed creating their respective
files, but only one will manage to bind. The other one must error out,
but it already created a file it is unclear what to do with.
