From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Sun, 5 Feb 2017 23:22:12 -0800
Message-ID: <CAM_iQpVG+ybcv1DAc01y3c=CRmUgMqocEnp-efhVM0c-t4hZ0w@mail.gmail.com>
References: <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
 <20170126232912.rgh6undqxd4tofqj@dhcp-1-212.brq.redhat.com>
 <CAM_iQpXqqmAGPbo6jNJV4bOco9sfvXukNAxYPp4tfL=CNwF-RA@mail.gmail.com>
 <20170127064143.ddyt43iglu2odlld@dhcp-1-212.brq.redhat.com>
 <CAM_iQpWSRjh4sV-hQxSAFsmvXZ1P4u959vm+UfCP55szQUb0-g@mail.gmail.com> <20170131181411.cq3o7yxrnhq6thpt@dhcp-1-212.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Mateusz Guzik <mguzik@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20170131181411.cq3o7yxrnhq6thpt@dhcp-1-212.brq.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2017 at 10:14 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
> On Mon, Jan 30, 2017 at 10:44:03PM -0800, Cong Wang wrote:
>> Mind being more specific?
>
> Consider 2 threads which bind the same socket, but with different paths.
>
> Currently exactly one file will get created, the one used to bind.
>
> With your patch both threads can succeed creating their respective
> files, but only one will manage to bind. The other one must error out,
> but it already created a file it is unclear what to do with.

In this case, it simply puts the path back:

        err = -EINVAL;
        if (u->addr)
                goto out_up;
[...]

out_up:
        mutex_unlock(&u->bindlock);
out_put:
        if (err)
                path_put(&path);
out:
        return err;


Which is what unix_release_sock() does too:

        if (path.dentry)
                path_put(&path);
