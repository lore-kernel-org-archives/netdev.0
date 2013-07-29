From: John Heffner <johnwheffner@gmail.com>
Subject: Re: A call to revise sockets behaviour
Date: Mon, 29 Jul 2013 15:00:11 -0400
Message-ID: <CABrhC0=TgBwdW1SaDgZRaYWYpqKvTY-c96JfGdMpSD0-e1+YKw@mail.gmail.com>
References: <2066879158.39771.1375110634453.JavaMail.mail@webmail09>
	<20130729083519.5d574f16@nehalam.linuxnetplumber.net>
	<2063167407.40450.1375112877907.JavaMail.mail@webmail09>
	<1375119778.10515.20.camel@edumazet-glaptop>
	<2134648871.43175.1375120936132.JavaMail.mail@webmail09>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, stephen@networkplumber.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "Artem S. Tashkinov" <t.artem@lycos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2134648871.43175.1375120936132.JavaMail.mail@webmail09>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 29, 2013 at 2:02 PM, Artem S. Tashkinov <t.artem@lycos.com> wrote:
> Jul 29, 2013 11:43:00 PM, Eric wrote:
> On Mon, 2013-07-29 at 15:47 +0000, Artem S. Tashkinov wrote:
>>
>>> A wine developer clearly showed that this option simply doesn't work.
>>>
>>> http://bugs.winehq.org/show_bug.cgi?id=26031#c21
>>>
>>> Output of strace:
>>> getsockopt(24, SOL_SOCKET, SO_REUSEADDR, [0], [4]) = 0
>>> setsockopt(24, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>>> bind(24, {sa_family=AF_INET, sin_port=htons(43012), sin_addr=inet_addr("0.
>>> 0.0.0")}, 16) = -1 EADDRINUSE (Address already in use)
>>
>>Its clear that some other socket did not use SO_REUSADDR
>>
>>All sockets using a given port _must_ have use SO_REUSADDR to allow this
>>port being reused.
>>
>
> It's exactly what's been tried. A program running with SO_REUSADDR, once no longer
> running consequently fails to regain the rights for the port.

To reiterate what Eric said, it seems likely that the listen socket on
which the currently-open sockets were created did not have
SO_REUSEADDR set.  If you follow the sequence:

a = socket()
bind(a, 0.0.0.0, P)
listen(a)
accept(a)
close(a)

b = socket()
setsockopt(b, SOL_SOCKET, SO_REUSEADDR, 1)
bind(b, 0.0.0.0, P)

this last bind() will fail.  If you insert setsocket(a, SOL_SOCKET,
SO_REUSEADDR, 1) before the first bind, (assuming all existing sockets
on port P have timed out and entered the CLOSED state), this program
will succeed.

Put another way, when creating a listen socket, the creator has
control over whether it's willing to allow any address reuse.  This is
strict -- if any existing connections exist, its bind will fail, and
if any of its future connections exist, binds at that time will fail
(regardless of whether that future socket has SO_REUSEADDR set).

  -John
