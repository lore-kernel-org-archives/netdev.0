From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] ipbatch: fix use of 'ip netns exec'
Date: Mon, 08 Jul 2013 11:41:16 +0200
Message-ID: <51DA893C.8070002@6wind.com>
References: <1373040345-11116-1-git-send-email-nicolas.dichtel@6wind.com> <1373057353.1913.55.camel@bwh-desktop.uk.level5networks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	junwei.zhang@6wind.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:55987 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab3GHJlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 05:41:22 -0400
Received: by mail-wg0-f45.google.com with SMTP id j13so3584024wgh.24
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 02:41:21 -0700 (PDT)
In-Reply-To: <1373057353.1913.55.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/07/2013 22:49, Ben Hutchings a =C3=A9crit :
> On Fri, 2013-07-05 at 18:05 +0200, Nicolas Dichtel wrote:
>> From: JunweiZhang <junwei.zhang@6wind.com>
>>
>> execvp() does not return when the command succeed, hence all command=
s in the
>> batch file after the line 'ip netns exec' are not executed.
>>
>> Let's fork before calling execvp().
>
> A Unix shell forks every command it runs, so why should ip do this to=
o?
Just to show the problem:

$ cat test.batch
netns add netns1
netns exec netns1 ip l
netns
$ ip -b test.batch
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT
     link/sit 0.0.0.0 brd 0.0.0.0

All command after 'netns exec' are never executed.

With the patch:
$ ip -b test.batch
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT
     link/sit 0.0.0.0 brd 0.0.0.0
netns1

Now, existing netns are displayed.

>
> [...]
>> +       return WIFEXITED(status) ? EXIT_SUCCESS : EXIT_FAILURE;
> [...]
>
> So you throw away the original exit code of the child process.
Right, should use WEXITSTATUS(). I will send a v2.

>
> I suspect your actual problem has to do with the exit code of the chi=
ld,
> and your shell script contains 'set -e'.
Maybe I miss something, but man execvp says:
"The exec() functions only return if an error has have occurred."
