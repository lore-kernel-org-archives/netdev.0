From: Isaac Boukris <iboukris@gmail.com>
Subject: Re: iproute: ss truncates abstract unix domain socket embedding null
Date: Tue, 18 Oct 2016 21:46:48 +0300
Message-ID: <CAC-fF8SdbDHPMZbOwHg=cOpsy+4ewTq9KGi-Cp=uaaG0hEJ8Fg@mail.gmail.com>
References: <CAC-fF8SMUsj8pPJO+VYdRSQAOcwyBpJY1C9V3VEk3zrFS=Jy4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35543 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932400AbcJRSqv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:46:51 -0400
Received: by mail-wm0-f48.google.com with SMTP id c78so11720062wme.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 11:46:50 -0700 (PDT)
In-Reply-To: <CAC-fF8SMUsj8pPJO+VYdRSQAOcwyBpJY1C9V3VEk3zrFS=Jy4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

On Sun, Oct 16, 2016 at 11:43 PM, Isaac Boukris <iboukris@gmail.com> wrote:
> Hello,
>
> The unix(7) man page says that null have no special meaning in
> abstract unix domain socket address (the length is specified
> therefore).
>
> However, when such name (embedding null) is used, ss (and netstat)
> will only show up to the first null occurrence (second technically, if
> we count the null prefix).
> e.g. the name "\0/tmp/fo\0.sock" is displayed as: "@/tmp/fo" (whilst
> strace tool shows it as: sun_path=@"/tmp/fo\0.sock").
>
> Would it be more useful if it printed the whole name and escaped the null?
> If so, would '\0' be ok for escaping the null?


Meanwhile, I've got it to escape the null character with with '\0' as suggested.
Can anyone take a look and advise if I'm on the right track? Thanks!


diff --git a/misc/ss.c b/misc/ss.c
index dd77b81..3e41f44 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2869,7 +2869,7 @@ static int unix_show_sock(const struct
sockaddr_nl *addr, struct nlmsghdr *nlh,
        struct filter *f = (struct filter *)arg;
        struct unix_diag_msg *r = NLMSG_DATA(nlh);
        struct rtattr *tb[UNIX_DIAG_MAX+1];
-       char name[128];
+       char name[128*2];
        struct sockstat stat = { .name = "*", .peer_name = "*" };

        parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr *)(r+1),
@@ -2891,11 +2891,25 @@ static int unix_show_sock(const struct
sockaddr_nl *addr, struct nlmsghdr *nlh,
        }
        if (tb[UNIX_DIAG_NAME]) {
                int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
+               char *real_name = RTA_DATA(tb[UNIX_DIAG_NAME]);

-               memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
-               name[len] = '\0';
-               if (name[0] == '\0')
+               if (real_name[0] == '\0') {
+                       int i, j;
                        name[0] = '@';
+                       for (i = j = 1; i < len; ++i) {
+                               if (real_name[i] == '\0') {
+                                       name[j++] = '\\';
+                                       name[j++] = '0';
+                               }
+                               else
+                                       name[j++] = real_name[i];
+                       }
+                       name[j] = '\0';
+               } else {
+                       memcpy(name, real_name, len);
+                       name[len] = '\0';
+               }
+
                stat.name = &name[0];
                memcpy(stat.local.data, &stat.name, sizeof(stat.name));
        }
