From: Daurnimator <quae@daurnimator.com>
Subject: EINVAL when using connect() for udp sockets
Date: Thu, 9 Mar 2017 14:10:52 +1100
Message-ID: <CAEnbY+cYpX8naDpRkXgwCP=i64AwWgK9=_7AacmYip-ykot7mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: William Ahern <william@25thandclement.com>, santitm99@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33853 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdCIEIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 23:08:15 -0500
Received: by mail-io0-f193.google.com with SMTP id n76so2868433ioe.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 20:08:14 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com. [209.85.214.41])
        by smtp.gmail.com with ESMTPSA id k63sm2433410ioi.19.2017.03.08.19.10.53
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 19:10:53 -0800 (PST)
Received: by mail-it0-f41.google.com with SMTP id m27so58805698iti.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 19:10:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When debugging https://github.com/daurnimator/lua-http/issues/73 which
uses https://github.com/wahern/dns we ran into an issue where modern
linux kernels return EINVAL if you try and re-use a udp socket.
The issue seems to occur if you go from a local destination ip to a
non-local one.

>From connect(2) man page:
> connectionless protocol sockets may use connect() multiple times to change their association

(the following content is also available at
https://gist.github.com/daurnimator/6765345776e87a3830ed101d1d983ee1)

$ cat connect-bug-stage2.c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <errno.h>

int main() {
    int fd = socket(PF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP);
    if (fd == -1)
        exit(1);
    if (bind(fd, (struct sockaddr*)&(struct
sockaddr_in){.sin_family=AF_INET, .sin_port=htons(57997),
.sin_addr=inet_addr("0.0.0.0")}, 16))
        exit(2);
    if (connect(fd, (struct sockaddr*)&(struct
sockaddr_in){.sin_family=AF_INET, .sin_port=htons(53),
.sin_addr=inet_addr("127.0.0.2")}, 16))
        exit(3);
    if (-1 == sendto(fd, "test", 4, 0, NULL, 0))
        exit(4);
    char buf[200];
    if (-1 != recvfrom(fd, buf, 200, 0, 0, 0) && errno != ECONNREFUSED)
        exit(5);
    /* okay, try next server... */
    if (connect(fd, (struct sockaddr*)&(struct
sockaddr_in){.sin_family=AF_INET, .sin_port=htons(53),
.sin_addr=inet_addr("8.8.8.8")}, 16))
        exit(6);
    exit(0);
}
$ gcc connect-bug-stage2.c
$ strace ./a.out
execve("./a.out", ["./a.out"], [/* 56 vars */]) = 0
brk(NULL) = 0x860000
access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=215350, ...}) = 0
mmap(NULL, 215350, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fc978791000
close(3) = 0
open("/usr/lib/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\260\3\2\0\0\0\0\0"...,
832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1951744, ...}) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0x7fc97878f000
mmap(NULL, 3791152, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3,
0) = 0x7fc978206000
mprotect(0x7fc97839b000, 2093056, PROT_NONE) = 0
mmap(0x7fc97859a000, 24576, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x194000) = 0x7fc97859a000
mmap(0x7fc9785a0000, 14640, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fc9785a0000
close(3) = 0
arch_prctl(ARCH_SET_FS, 0x7fc978790400) = 0
mprotect(0x7fc97859a000, 16384, PROT_READ) = 0
mprotect(0x600000, 4096, PROT_READ) = 0
mprotect(0x7fc9787c6000, 4096, PROT_READ) = 0
munmap(0x7fc978791000, 215350) = 0
socket(AF_INET, SOCK_DGRAM|SOCK_CLOEXEC|SOCK_NONBLOCK, IPPROTO_IP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(57997),
sin_addr=inet_addr("0.0.0.0")}, 16) = 0
connect(3, {sa_family=AF_INET, sin_port=htons(53),
sin_addr=inet_addr("127.0.0.2")}, 16) = 0
sendto(3, "test", 4, 0, NULL, 0) = 4
recvfrom(3, 0x7ffcc2c9a3a0, 200, 0, NULL, NULL) = -1 ECONNREFUSED
(Connection refused)
connect(3, {sa_family=AF_INET, sin_port=htons(53),
sin_addr=inet_addr("8.8.8.8")}, 16) = -1 EINVAL (Invalid argument)
exit_group(6) = ?
+++ exited with 6 +++
