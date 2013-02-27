From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] drivers/isdn: about the loop after call isdn_tty_send_msg
Date: Wed, 27 Feb 2013 17:32:35 +0800
Message-ID: <512DD2B3.2070404@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:54723 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146Ab3B0Jcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 04:32:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

  do we need break out of the loop after call isdn_tty_send_msg ?
    p is not increased after finish calling isdn_tty_send_msg.
    and then will loop back to process the p again.

  do we intend to scan again the string which appended "+M..." ?

  we also assume "+M..." is a NUL terminated string, is it OK ? (it seems ok)


  thanks.

gchen.


in drivers/isdn/i4l/isdn_tty.c:


3408 static void
3409 isdn_tty_parse_at(modem_info *info)
3410 {
3411         atemu *m = &info->emu;
3412         char *p;
3413         char ds[ISDN_MSNLEN];
3414
3415 #ifdef ISDN_DEBUG_AT
3416         printk(KERN_DEBUG "AT: '%s'\n", m->mdmcmd);
3417 #endif
3418         for (p = &m->mdmcmd[2]; *p;) {
3419                 switch (*p) {
3420                 case ' ':
3421                         p++;
3422                         break;
...

3559                 case '+':
3560                         p++;
3561                         switch (*p) {
3562 #ifdef CONFIG_ISDN_AUDIO
3563                         case 'F':
3564                                 p++;
3565                                 if (isdn_tty_cmd_PLUSF(&p, info))
3566                                         return;
3567                                 break;
3568                         case 'V':
3569                                 if ((!(m->mdmreg[REG_SI1] & 1)) ||
3570                                     (m->mdmreg[REG_L2PROT] == ISDN_PROTO_L2_MODEM))
3571                                         PARSE_ERROR;
3572                                 p++;
3573                                 if (isdn_tty_cmd_PLUSV(&p, info))
3574                                         return;
3575                                 break;
3576 #endif                          /* CONFIG_ISDN_AUDIO */
3577                         case 'S':       /* SUSPEND */
3578                                 p++;
3579                                 isdn_tty_get_msnstr(ds, &p);
3580                                 isdn_tty_suspend(ds, info, m);
3581                                 break;
3582                         case 'R':       /* RESUME */
3583                                 p++;
3584                                 isdn_tty_get_msnstr(ds, &p);
3585                                 isdn_tty_resume(ds, info, m);
3586                                 break;
3587                         case 'M':       /* MESSAGE */
3588                                 p++;
3589                                 isdn_tty_send_msg(info, m, p);
3590                                 break;
3591                         default:
3592                                 PARSE_ERROR;
3593                         }
3594                         break;
3595                 case '&':
3596                         p++;
3597                         if (isdn_tty_cmd_ATand(&p, info))
3598                                 return;
3599                         break;
3600                 default:
3601                         PARSE_ERROR;
3602                 }
3603         }
3604 #ifdef CONFIG_ISDN_AUDIO
3605         if (!info->vonline)
3606 #endif
3607                 isdn_tty_modem_result(RESULT_OK, info);
3608 }
