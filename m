From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Fri, 28 Nov 2003 09:40:22 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128.094022.106776635.yoshfuji@linux-ipv6.org>
References: <1069974209.5349.7.camel@teapot.felipe-alfaro.com>
	<20031128.092326.39861126.yoshfuji@linux-ipv6.org>
	<20031128.092642.47232575.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, davem@redhat.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: felipe_alfaro@linuxmail.org
In-Reply-To: <20031128.092642.47232575.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031128.092642.47232575.yoshfuji@linux-ipv6.org> (at Fri, 28 Nov 2003 09:26:42 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> >  3)   if (len)
> >          strncpy(dst, src, len - 1);
> >       dst[len] = 0;

grr, another mistake...:

          if (len) {
             strncpy(dst, src, len - 1);
             dst[len - 1];
          }

----------------
1) use strlcpy0(dst, src, len)

size_t strlcpy0(char *dst, const char *src, size_t maxlen)
{
  size_t len = strlcpy(dst, src, maxlen);
  if (likely(maxlen != 0) && len < maxlen - 1)
    memset(dst + len + 1, 0, maxlen - len - 1);
}

2a) use strncpy0(dst, src, len)

char *strncpy0(char *dst, const char *src, size_t maxlen)
{
  memset(dst, 0, maxlen);
  if (likely(maxlen != 0))
    strncpy(dst, src, maxlen - 1);
}

2b) fix strncpy() to zero-out rest of destination buffer 
    and use strncpy0(dst, src, len)

char *strncpy0(char *dst, const char *src, size_t maxlen)
{
  if (likely(maxlen != 0)) {
    strncpy(dst, src, maxlen - 1);
    dst[maxlen - 1] = 0;
  }
}


I prefer 1 > 2b >> 2a.

--yoshfuji
