From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: 6pack: stack-out-of-bounds in sixpack_receive_buf
Date: Mon, 5 Sep 2016 19:55:26 +0200
Message-ID: <CACT4Y+a97u7XL+Zfe634io44vhgLvVjXhL5ejWBaevaXgn-nOQ@mail.gmail.com>
References: <CACT4Y+ZXH227Gbwrr+dUN4WSFNsoSECYd-KaZyLJ8F0KCRWRBw@mail.gmail.com>
 <CACT4Y+bhAODvzqOxQps+4y6xSRBXC7pr18wRA+bb26c2XgPFhA@mail.gmail.com> <20160905184953.00bb448a@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Peter Hurley <peter@hurleysoftware.com>,
        Jiri Slaby <jslaby@suse.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Andreas Koensgen <ajk@comnets.uni-bremen.de>,
        linux-hams@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        syzkaller <syzkaller@googlegroups.com>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20160905184953.00bb448a@lxorguk.ukuu.org.uk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 5, 2016 at 7:49 PM, One Thousand Gnomes
<gnomes@lxorguk.ukuu.org.uk> wrote:
>> different runs). Looking at code, the following looks suspicious -- we
>> limit copy by 512 bytes, but use the original count which can be
>> larger than 512:
>>
>> static void sixpack_receive_buf(struct tty_struct *tty,
>>     const unsigned char *cp, char *fp, int count)
>> {
>>     unsigned char buf[512];
>>     ....
>>     memcpy(buf, cp, count < sizeof(buf) ? count : sizeof(buf));
>>     ....
>>     sixpack_decode(sp, buf, count1);
>>
>>
>> On commit 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next.
>
> With the sane tty locking we now have I believe the following is safe as
> we consume the bytes and move them into the decoded buffer before
> returning.
>
> diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
> index 5a1e985..470b3dc 100644
> --- a/drivers/net/hamradio/6pack.c
> +++ b/drivers/net/hamradio/6pack.c
> @@ -127,7 +127,7 @@ struct sixpack {
>
>  #define AX25_6PACK_HEADER_LEN 0
>
> -static void sixpack_decode(struct sixpack *, unsigned char[], int);
> +static void sixpack_decode(struct sixpack *, const unsigned char[], int);
>  static int encode_sixpack(unsigned char *, unsigned char *, int, unsigned char);
>
>  /*
> @@ -428,7 +428,7 @@ out:
>
>  /*
>   * Handle the 'receiver data ready' interrupt.
> - * This function is called by the 'tty_io' module in the kernel when
> + * This function is called by the tty module in the kernel when
>   * a block of 6pack data has been received, which can now be decapsulated
>   * and sent on to some IP layer for further processing.
>   */
> @@ -436,7 +436,6 @@ static void sixpack_receive_buf(struct tty_struct *tty,
>         const unsigned char *cp, char *fp, int count)
>  {
>         struct sixpack *sp;
> -       unsigned char buf[512];
>         int count1;
>
>         if (!count)
> @@ -446,10 +445,7 @@ static void sixpack_receive_buf(struct tty_struct *tty,
>         if (!sp)
>                 return;
>
> -       memcpy(buf, cp, count < sizeof(buf) ? count : sizeof(buf));
> -
>         /* Read the characters out of the buffer */
> -
>         count1 = count;
>         while (count) {
>                 count--;
> @@ -459,7 +455,7 @@ static void sixpack_receive_buf(struct tty_struct *tty,
>                         continue;
>                 }
>         }
> -       sixpack_decode(sp, buf, count1);
> +       sixpack_decode(sp, cp, count1);
>
>         sp_put(sp);
>         tty_unthrottle(tty);
> @@ -992,7 +988,7 @@ static void decode_std_command(struct sixpack *sp, unsigned char cmd)
>  /* decode a 6pack packet */
>
>  static void
> -sixpack_decode(struct sixpack *sp, unsigned char *pre_rbuff, int count)
> +sixpack_decode(struct sixpack *sp, const unsigned char *pre_rbuff, int count)
>  {
>         unsigned char inbyte;
>         int count1;


Applied locally for testing. I will notify if I see this bug again.
Thanks!
