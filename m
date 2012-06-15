From: Li Yu <raise.sail@gmail.com>
Subject: Re: [RFC] Introduce to batch variants of accept() and epoll_ctl()
 syscall
Date: Fri, 15 Jun 2012 13:37:42 +0800
Message-ID: <4FDACA26.70004@gmail.com>
References: <4FDAB652.6070201@gmail.com> <CABa6K_H3NrvvZ3Bh7JqsR6h33BSqYPBenUDG5Yt1U=2VvP700g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davidel@xmailserver.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABa6K_H3NrvvZ3Bh7JqsR6h33BSqYPBenUDG5Yt1U=2VvP700g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8815=E6=97=A5 12:29, Changli Gao =E5=86=
=99=E9=81=93:
> On Fri, Jun 15, 2012 at 12:13 PM, Li Yu<raise.sail@gmail.com>  wrote:
>> Hi,
>>
>>   We encounter a performance problem in a large scale computer
>> cluster, which needs to handle a lot of incoming concurrent TCP
>> connection requests.
>>
>>   The top shows the kernel is most cpu hog, the testing is simple,
>> just a accept() ->  epoll_ctl(ADD) loop, the ratio of cpu util sys% =
to
>> si% is about 2:5.
>>
>>   I also asked some experienced webserver/proxy developers in my tea=
m
>> for suggestions, it seem that behavior of many userland programs alr=
eady
>> called accept() multiple times after it is waked up by
>> epoll_wait(). And the common action is adding the fd that accept()
>> return into epoll interface by epoll_ctl() syscall then.
>>
>>   Therefore, I think that we'd better to introduce to batch variants=
 of
>> accept() and epoll_ctl() syscall, just like sendmmsg() or recvmmsg()=
=2E
>>
>>   For accept(), we may need a new syscall, it may like this,
>>
>>   struct accept_result {
>>       int fd;
>>       struct sockaddr addr;
>>       socklen_t addr_len;
>>   };
>>
>>   int maccept4(int fd, int flags, int nr_accept_result, struct
>> accept_result *results);
>>
>>   For epoll_ctl(), there are two means to extend it, I prefer to ext=
end
>> current interface instead of introduce to new syscall. We may introd=
uce
>> to a new flag EPOLL_CTL_BATCH. If userland call epoll_ctl() with thi=
s
>> flag set, the meaning of last two arguments of epoll_ctl() change, .=
e.g:
>>
>>   struct batch_epoll_event batch_event[] =3D {
>>          {
>>               .fd =3D a_newsock_fd;
>>               .epoll_event =3D { ... };
>>          },
>>          ...
>>   };
>>
>>   ret =3D epoll_ctl(fd, EPOLL_CTL_ADD|EPOLL_CTL_BATCH, nr_batch_even=
ts,
>> batch_events);
>>
>
> I think it is good idea. Would you please implement a prototype and
> give some numbers? This kind of data may help selling this idea.
> Thanks.
>

Of course, I think that implementing them should not be a hard work :)

Em. I really do not know whether it is necessary to introduce to a new=20
syscall here. An alternative solution to add new socket option to handl=
e=20
such batch requirement, so applications also can detect if kernel has=20
this extended ability with a easy getsockopt() call.

Any way, I am going to try to write a prototype first.

Thanks

Yu
